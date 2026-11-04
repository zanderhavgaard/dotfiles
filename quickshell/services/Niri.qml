pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Mirrors niri's state from `niri msg --json event-stream`.
// Every update reassigns the property so QML bindings re-evaluate.
// Only workspaces and keyboard layouts are tracked; window events are ignored
// (an empty workspace is one with no active_window_id).
Singleton {
    id: root

    property var workspaces: []      // sorted by output, then idx
    property var layoutNames: []
    property int layoutIdx: 0

    readonly property string layoutShort: shortLayout(layoutNames[layoutIdx] ?? "")

    function workspacesOn(output) {
        return workspaces.filter(w => w.output === output);
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
