import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services

// App launcher: launch history, matching and ranking. The window itself is
// LauncherWindow.qml. Toggle with `qs ipc call launcher toggle`.
// Tab / Shift+Tab (or arrows, Ctrl+N/P) move through results, wrapping;
// Enter opens; Esc closes.
Scope {
    id: root

    property bool open: false

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.open = !root.open; }
        function show(): void { root.open = true; }
        function hide(): void { root.open = false; }
    }

    LazyLoader {
        active: root.open
        LauncherWindow { launcher: root }
    }

    // ---- launch history (frecency) -------------------------------------
    // { "<desktop entry id>": { "score": n, "last": epochMs } }
    // Each launch decays the old score by elapsed time, then adds 1.
    readonly property real halfLifeMs: 7 * 24 * 3600 * 1000
    property var history: ({})

    FileView {
        id: historyFile
        path: Quickshell.statePath("launcher-history.json")
        blockLoading: true
        printErrors: false   // missing on first run
        onLoaded: {
            try {
                root.history = JSON.parse(text());
            } catch (e) {
                root.history = {};
            }
        }
    }

    function frecency(id) {
        const h = history[id];
        if (!h) return 0;
        return h.score * Math.pow(0.5, (Date.now() - h.last) / halfLifeMs);
    }

    function launch(entry) {
        const next = Object.assign({}, history);
        next[entry.id] = { score: frecency(entry.id) + 1, last: Date.now() };
        history = next;
        historyFile.setText(JSON.stringify(next));

        if (entry.runInTerminal) Status.inTerminal(entry.command);
        else entry.execute();
        open = false;
    }

    // ---- matching ----------------------------------------------------------
    // subsequence match; returns matched indices or null
    function fuzzy(q, s) {
        const hay = s.toLowerCase();
        const idx = [];
        let j = 0;
        for (let i = 0; i < hay.length && j < q.length; i++) {
            if (hay[i] === q[j]) {
                idx.push(i);
                j++;
            }
        }
        return j === q.length ? idx : null;
    }

    // match quality tier: 0 prefix, 1 substring, 2 scattered letters
    function tier(q, name) {
        const n = name.toLowerCase();
        if (n.startsWith(q)) return 0;
        if (n.includes(q)) return 1;
        return 2;
    }

    // ordering: match tier, then usage, then tighter fuzzy span, then name
    function compare(a, b) {
        return a.tier - b.tier
            || b.usage - a.usage
            || a.span - b.span
            || a.name.localeCompare(b.name);
    }

    function escapeHtml(s) {
        return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    }

    // highlight matched letters in yellow (StyledText)
    function highlight(s, idx) {
        const set = new Set(idx);
        let out = "";
        for (let i = 0; i < s.length; i++)
            out += set.has(i) ? "<font color=\"" + Theme.yellow + "\">" + escapeHtml(s[i]) + "</font>" : escapeHtml(s[i]);
        return out;
    }

    // the top 8 apps for a query
    function appResults(query) {
        const q = query.trim().toLowerCase();
        const out = [];
        for (const app of DesktopEntries.applications.values) {
            if (app.noDisplay) continue;
            const idx = q === "" ? [] : fuzzy(q, app.name);
            if (idx === null) continue;
            out.push({
                entry: app,
                title: highlight(app.name, idx),
                subtitle: app.genericName || app.comment || "",
                icon: app.icon,
                letter: app.name.charAt(0).toUpperCase(),
                tier: q === "" ? 0 : tier(q, app.name),
                usage: frecency(app.id),
                span: idx.length ? idx[idx.length - 1] - idx[0] : 0,
                name: app.name,
            });
        }
        out.sort(compare);
        return out.slice(0, 8);
    }
}
