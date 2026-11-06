pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Mirrors niri's state from `niri msg --json event-stream`.
// Every update reassigns the property so QML bindings re-evaluate.
// Tracks workspaces, windows (for the bar's column map) and keyboard layouts.
Singleton {
    id: root

    property var workspaces: []      // sorted by output, then idx
    property var windows: []         // niri's window objects, unordered
    property var layoutNames: []
    property int layoutIdx: 0

    readonly property string layoutShort: shortLayout(layoutNames[layoutIdx] ?? "")

    function workspacesOn(output) {
        return workspaces.filter(w => w.output === output);
    }

    // The tiled columns of a workspace, left to right, for the column map:
    // [{ width, windows: [{ height, focused, shown }] }]. Sizes are niri's
    // logical pixels; `shown` is whether the tile is in view right now.
    function columnsOf(workspaceId) {
        const cols = [];
        for (const w of windows) {
            const pos = w.layout ? w.layout.pos_in_scrolling_layout : null;
            if (w.workspace_id !== workspaceId || w.is_floating || !pos) continue;
            const col = cols[pos[0] - 1] = cols[pos[0] - 1] || { width: 0, windows: [] };
            col.width = Math.max(col.width, w.layout.tile_size[0]);
            col.windows[pos[1] - 1] = {
                height: w.layout.tile_size[1],
                focused: w.is_focused,
                shown: w.layout.tile_pos_in_workspace_view !== null,
            };
        }
        return cols.filter(c => c).map(c => ({ width: c.width, windows: c.windows.filter(w => w) }));
    }

    function patchWindows(test, fields) {
        windows = windows.map(w => test(w) ? Object.assign({}, w, fields(w)) : w);
    }

    function action(args) {
        Quickshell.execDetached(["niri", "msg", "action"].concat(args));
    }

    function focusWorkspace(ws) {
        // the CLI takes a per-output index, so focus that output first
        Quickshell.execDetached(["sh", "-c",
            "niri msg action focus-monitor \"$1\" && niri msg action focus-workspace \"$2\"",
            "sh", ws.output, String(ws.idx)]);
    }

    function shortLayout(name) {
        if (name.startsWith("English")) return "us";
        if (name.startsWith("Danish")) return "dk";
        return name.slice(0, 2).toLowerCase();
    }

    function sortWorkspaces(list) {
        return list.slice().sort((a, b) => a.output === b.output
            ? a.idx - b.idx
            : String(a.output).localeCompare(String(b.output)));
    }

    function handle(ev) {
        if (ev.WorkspacesChanged) {
            workspaces = sortWorkspaces(ev.WorkspacesChanged.workspaces);
        } else if (ev.WorkspaceActivated) {
            const { id, focused } = ev.WorkspaceActivated;
            const target = workspaces.find(w => w.id === id);
            if (!target) return;
            workspaces = workspaces.map(w => Object.assign({}, w, {
                is_active: w.output === target.output ? w.id === id : w.is_active,
                is_focused: focused ? w.id === id : w.is_focused,
            }));
        } else if (ev.WorkspaceActiveWindowChanged) {
            const e = ev.WorkspaceActiveWindowChanged;
            workspaces = workspaces.map(w => w.id === e.workspace_id
                ? Object.assign({}, w, { active_window_id: e.active_window_id })
                : w);
        } else if (ev.WorkspaceUrgencyChanged) {
            const e = ev.WorkspaceUrgencyChanged;
            workspaces = workspaces.map(w => w.id === e.id ? Object.assign({}, w, { is_urgent: e.urgent }) : w);
        } else if (ev.WindowsChanged) {
            windows = ev.WindowsChanged.windows;
        } else if (ev.WindowOpenedOrChanged) {
            const win = ev.WindowOpenedOrChanged.window;
            const rest = windows.filter(w => w.id !== win.id);
            windows = (win.is_focused ? rest.map(w => w.is_focused ? Object.assign({}, w, { is_focused: false }) : w) : rest)
                .concat([win]);
        } else if (ev.WindowClosed) {
            windows = windows.filter(w => w.id !== ev.WindowClosed.id);
        } else if (ev.WindowFocusChanged) {
            const id = ev.WindowFocusChanged.id;
            patchWindows(w => w.is_focused !== (w.id === id), w => ({ is_focused: w.id === id }));
        } else if (ev.WindowLayoutsChanged) {
            const changed = new Map(ev.WindowLayoutsChanged.changes);
            patchWindows(w => changed.has(w.id), w => ({ layout: changed.get(w.id) }));
        } else if (ev.WindowUrgencyChanged) {
            const e = ev.WindowUrgencyChanged;
            patchWindows(w => w.id === e.id, w => ({ is_urgent: e.urgent }));
        } else if (ev.KeyboardLayoutsChanged) {
            layoutNames = ev.KeyboardLayoutsChanged.keyboard_layouts.names;
            layoutIdx = ev.KeyboardLayoutsChanged.keyboard_layouts.current_idx;
        } else if (ev.KeyboardLayoutSwitched) {
            layoutIdx = ev.KeyboardLayoutSwitched.idx;
        }
    }

    Process {
        id: stream
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    root.handle(JSON.parse(line));
                } catch (e) {
                    console.warn("niri: bad event line:", e);
                }
            }
        }
        // niri restarted or the socket went away: reconnect
        onExited: restart.start()
    }

    Timer {
        id: restart
        interval: 1000
        onTriggered: stream.running = true
    }
}
