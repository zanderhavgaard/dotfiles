import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs

// App launcher. Toggle with `qs ipc call launcher toggle`.
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
                root.historyLoaded = true;
            } catch (e) {
                root.history = {};
            }
        }
    }

    property bool historyLoaded: false

    // first run (no history file yet): seed from fuzzel's launch counts so
    // ranking works from day one
    Timer {
        interval: 1000
        running: true
        onTriggered: if (!root.historyLoaded) root.seedFromFuzzel()
    }

    // ~/.cache/fuzzel lines look like "firefox.desktop|42". sqrt keeps old
    // heavy hitters from drowning out new launches; they decay like the rest.
    FileView {
        id: fuzzelCache
        path: Quickshell.env("HOME") + "/.cache/fuzzel"
        blockLoading: true
        printErrors: false
    }

    function seedFromFuzzel() {
        const seeded = {};
        const now = Date.now();
        for (const line of fuzzelCache.text().split("\n")) {
            const [file, count] = line.split("|");
            const n = parseInt(count);
            if (!file || isNaN(n)) continue;
            seeded[file.replace(/\.desktop$/, "")] = { score: Math.sqrt(n), last: now };
        }
        history = seeded;
        historyLoaded = true;
        historyFile.setText(JSON.stringify(seeded));
    }

    function frecency(id) {
        const h = history[id];
        if (!h) return 0;
        return h.score * Math.pow(0.5, (Date.now() - h.last) / halfLifeMs);
    }

    function recordLaunch(id) {
        const now = Date.now();
        const next = Object.assign({}, history);
        next[id] = { score: frecency(id) + 1, last: now };
        history = next;
        historyFile.setText(JSON.stringify(next));
    }

    LazyLoader {
        active: root.open

        PanelWindow {
            id: win

            property string query: ""
            property int selected: 0

            readonly property var results: appResults(query)

            onQueryChanged: selected = 0

            // move the selection by n, wrapping around both ends
            function step(n) {
                const len = results.length;
                if (len > 0) selected = ((selected + n) % len + len) % len;
            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore
            color: "#7316161D"   // sumiInk0 at 45%: dims the desktop
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "qs-launcher"

            // ---- matching ----------------------------------------------
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

            // highlight matched letters in carpYellow
            function highlight(s, idx) {
                const set = new Set(idx);
                let out = "";
                for (let i = 0; i < s.length; i++)
                    out += set.has(i) ? "<font color=\"" + Theme.carpYellow + "\">" + escapeHtml(s[i]) + "</font>" : escapeHtml(s[i]);
                return out;
            }

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
                        usage: root.frecency(app.id),
                        span: idx.length ? idx[idx.length - 1] - idx[0] : 0,
                        name: app.name,
                    });
                }
                out.sort(compare);
                return out.slice(0, 8);
            }

            function activate(r) {
                if (!r) return;
                root.recordLaunch(r.entry.id);
                if (r.entry.runInTerminal)
                    Quickshell.execDetached(["ghostty", "-e"].concat(r.entry.command));
                else
                    r.entry.execute();
                root.open = false;
            }

            // click outside the card closes
            MouseArea {
                anchors.fill: parent
                onClicked: root.open = false
            }

            // ---- card ----------------------------------------------------
            Rectangle {
                id: card
                anchors.horizontalCenter: parent.horizontalCenter
                y: Math.round(parent.height * 0.18)
                width: 560
                height: content.implicitHeight + 2
                color: Theme.sumiInk0
                border.width: 1
                border.color: Theme.sumiInk5

                // swallow clicks so they don't reach the close-on-click area
                MouseArea {
                    anchors.fill: parent
                }

                Column {
                    id: content
                    x: 1
                    y: 1
                    width: parent.width - 2

                    // header: wave pattern + 起動
                    Item {
                        width: parent.width
                        height: 56

                        Seigaiha {
                            anchors.fill: parent
                        }
                        Row {
                            anchors { left: parent.left; leftMargin: 18; bottom: parent.bottom; bottomMargin: 10 }
                            spacing: 10

                            Text {
                                id: headTitle
                                text: "起動"
                                color: Theme.fujiWhite
                                font.family: Theme.serif
                                font.pixelSize: 20
                                font.bold: true
                            }
                            Text {
                                anchors.baseline: headTitle.baseline
                                text: "launch"
                                color: Theme.oldWhite
                                font.family: Theme.sans
                                font.pixelSize: 11
                            }
                        }
                    }

                    // search field
                    Item {
                        width: parent.width
                        height: 48

                        Text {
                            id: prompt
                            anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
                            text: "❯"
                            color: Theme.crystalBlue
                            font.family: Theme.mono
                            font.pixelSize: 15
                        }

                        TextInput {
                            id: input
                            anchors {
                                left: prompt.right
                                leftMargin: 10
                                right: parent.right
                                rightMargin: 18
                                verticalCenter: parent.verticalCenter
                            }
                            focus: true
                            color: Theme.fujiWhite
                            selectionColor: Theme.waveBlue2
                            font.family: Theme.mono
                            font.pixelSize: 15
                            onTextChanged: win.query = text

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Escape) {
                                    root.open = false;
                                } else if (event.key === Qt.Key_Backtab || event.key === Qt.Key_Up
                                           || (event.key === Qt.Key_P && event.modifiers & Qt.ControlModifier)) {
                                    win.step(-1);
                                } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Down
                                           || (event.key === Qt.Key_N && event.modifiers & Qt.ControlModifier)) {
                                    win.step(1);
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    win.activate(win.results[win.selected]);
                                } else {
                                    return;
                                }
                                event.accepted = true;
                            }
                        }

                        Rectangle {
                            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                            height: 1
                            color: Theme.sumiInk4
                        }
                    }

                    // results
                    Column {
                        width: parent.width
                        topPadding: 8
                        bottomPadding: 8
                        leftPadding: 8
                        rightPadding: 8
                        spacing: 2

                        Repeater {
                            model: win.results

                            delegate: Rectangle {
                                id: row
                                required property var modelData
                                required property int index
                                readonly property bool isSelected: index === win.selected

                                width: parent.width - 16
                                height: 46
                                color: isSelected ? Theme.waveBlue2 : "transparent"

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: win.selected = row.index
                                    onClicked: win.activate(row.modelData)
                                }

                                // icon, or a letter tile when there isn't one
                                Rectangle {
                                    id: tile
                                    anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                                    width: 28
                                    height: 28
                                    color: row.isSelected ? Theme.waveBlue1 : Theme.sumiInk4

                                    IconImage {
                                        id: icon
                                        anchors.centerIn: parent
                                        implicitSize: 22
                                        source: Quickshell.iconPath(row.modelData.icon, true)
                                        visible: source != ""
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        visible: !icon.visible
                                        text: row.modelData.letter
                                        color: Theme.crystalBlue
                                        font.family: Theme.mono
                                        font.pixelSize: 12
                                    }
                                }

                                Column {
                                    anchors {
                                        left: tile.right
                                        leftMargin: 12
                                        right: enter.left
                                        rightMargin: 12
                                        verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        width: parent.width
                                        text: row.modelData.title
                                        textFormat: Text.StyledText
                                        elide: Text.ElideRight
                                        color: Theme.fujiWhite
                                        font.family: Theme.sans
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                    }
                                    Text {
                                        width: parent.width
                                        visible: text !== ""
                                        text: row.modelData.subtitle
                                        elide: Text.ElideRight
                                        color: row.isSelected ? Theme.oldWhite : Theme.mutedText
                                        font.family: Theme.sans
                                        font.pixelSize: 11
                                    }
                                }

                                Text {
                                    id: enter
                                    anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                                    visible: row.isSelected
                                    text: "↵"
                                    color: Theme.oldWhite
                                    font.family: Theme.mono
                                    font.pixelSize: 11
                                }
                            }
                        }

                        Text {
                            visible: win.results.length === 0
                            leftPadding: 12
                            topPadding: 8
                            bottomPadding: 8
                            text: "no matches"
                            color: Theme.mutedText
                            font.family: Theme.sans
                            font.pixelSize: 12
                        }
                    }

                    // footer
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.sumiInk4
                    }
                    Item {
                        width: parent.width
                        height: 34

                        Row {
                            anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
                            spacing: 16

                            Repeater {
                                model: [["↵", "open"], ["⇥", "next"], ["esc", "close"]]
                                delegate: Text {
                                    required property var modelData
                                    text: "<font color=\"" + Theme.fujiWhite + "\">" + modelData[0] + "</font> " + modelData[1]
                                    textFormat: Text.StyledText
                                    color: Theme.mutedText
                                    font.family: Theme.mono
                                    font.pixelSize: 11
                                }
                            }
                        }
                        Text {
                            anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
                            text: "quickshell"
                            color: Theme.mutedText
                            font.family: Theme.mono
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
}
