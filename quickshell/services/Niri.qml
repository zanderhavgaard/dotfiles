pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Mirrors niri's state from `niri msg --json event-stream`.
// Every update reassigns the property so QML bindings re-evaluate.
Singleton {
    id: root

    property var workspaces: []      // sorted by output, then idx
    property var windows: ({})       // id -> window object
    property var focusedWindowId: null
    property var layoutNames: []
    property int layoutIdx: 0
    property bool overviewOpen: false

    readonly property var focusedWindow: focusedWindowId !== null ? (windows[focusedWindowId] ?? null) : null
    readonly property string layoutShort: shortLayout(layoutNames[layoutIdx] ?? "")

    function workspacesOn(output) {
        return workspaces.filter(w => w.output === output);
    }

    // the window shown on this output's active workspace
    function activeWindowOn(output) {
        const ws = workspaces.find(w => w.output === output && w.is_active);
        if (!ws || ws.active_window_id === null) return null;
        return windows[ws.active_window_id] ?? null;
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

    function focusWindow(id) {
        action(["focus-window", "--id", String(id)]);
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
            const map = {};
            let focused = null;
            for (const win of ev.WindowsChanged.windows) {
                map[win.id] = win;
                if (win.is_focused) focused = win.id;
            }
            windows = map;
            focusedWindowId = focused;
        } else if (ev.WindowOpenedOrChanged) {
            const win = ev.WindowOpenedOrChanged.window;
            const map = Object.assign({}, windows);
            map[win.id] = win;
            windows = map;
            if (win.is_focused) focusedWindowId = win.id;
        } else if (ev.WindowClosed) {
            const map = Object.assign({}, windows);
            delete map[ev.WindowClosed.id];
            windows = map;
            if (focusedWindowId === ev.WindowClosed.id) focusedWindowId = null;
        } else if (ev.WindowFocusChanged) {
            focusedWindowId = ev.WindowFocusChanged.id;
        } else if (ev.KeyboardLayoutsChanged) {
            layoutNames = ev.KeyboardLayoutsChanged.keyboard_layouts.names;
            layoutIdx = ev.KeyboardLayoutsChanged.keyboard_layouts.current_idx;
        } else if (ev.KeyboardLayoutSwitched) {
            layoutIdx = ev.KeyboardLayoutSwitched.idx;
        } else if (ev.OverviewOpenedOrClosed) {
            overviewOpen = ev.OverviewOpenedOrClosed.is_open;
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
