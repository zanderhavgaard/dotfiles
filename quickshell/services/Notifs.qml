pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

// Notification server + state shared by the popups, the notification
// center and the bar's bell.
//
// The history is our own list of records, not the server's tracked set:
// most apps (Signal, Discord, Firefox, ...) close their own notifications a
// few seconds after sending them, which would otherwise wipe them from the
// center. A record outlives its notification; it just loses its actions.
// The history is in memory only: a quickshell restart (or logout) clears it.
//
// `popupKeys` is the subset currently shown as popups; a popup timing out
// only removes it from there. Do-not-disturb skips popups (except critical).
//
//   qs ipc call notifications toggle   open / close the center
//   qs ipc call notifications dnd      toggle do-not-disturb
//   qs ipc call notifications clear    dismiss everything
Singleton {
    id: root

    readonly property int maxHistory: 100

    property bool dnd: false
    property bool centerOpen: false
    property var popupKeys: []
    property date now: new Date()    // ticks so "5m" age labels update

    // newest first. Record:
    // { key, notif (live Notification or null), appName, summary, body, urgency, time, transient }
    property var history: []
    property int nextKey: 1

    readonly property int count: history.length
    readonly property var popups: history.filter(r => popupKeys.includes(r.key) && r.notif !== null)

    function update(key, fn) {
        history = history.map(r => r.key === key ? fn(Object.assign({}, r)) : r);
    }

    function remove(key) {
        history = history.filter(r => r.key !== key);
        popupKeys = popupKeys.filter(k => k !== key);
    }

    // ---- server ----------------------------------------------------------
    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        persistenceSupported: true
        // the history is our own list; re-emitting on reload would duplicate it
        keepOnReload: false

        onNotification: n => {
            n.tracked = true;
            const key = root.nextKey++;
            const rec = {
                key: key,
                notif: n,
                appName: n.appName,
                summary: n.summary,
                body: n.body,
                urgency: n.urgency,
                time: Date.now(),
                transient: n.transient,
            };
            root.history = [rec].concat(root.history).slice(0, root.maxHistory);
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.popupKeys = root.popupKeys.concat([key]);

            // the app (or a timeout) closed it: keep the record, drop the
            // live object and its popup. Transient ones don't belong in history.
            n.closed.connect(reason => {
                if (rec.transient) {
                    root.remove(key);
                } else {
                    root.update(key, r => Object.assign(r, { notif: null }));
                    root.popupKeys = root.popupKeys.filter(k => k !== key);
                }
            });
        }
    }

    // ---- actions -----------------------------------------------------------
    function hidePopup(rec) {
        popupKeys = popupKeys.filter(k => k !== rec.key);
        // transient notifications aren't meant for the history
        if (rec.transient && rec.notif) rec.notif.expire();
    }

    function dismiss(rec) {
        remove(rec.key);
        if (rec.notif) rec.notif.dismiss();
    }

    function clearAll() {
        for (const r of history)
            if (r.notif) r.notif.dismiss();
        history = [];
        popupKeys = [];
    }

    function toggleCenter() {
        centerOpen = !centerOpen;
        // opening the center replaces the popups
        if (centerOpen) popupKeys = [];
    }

    // "now", "5m", "2h", today's time, or a date for older ones
    function age(rec) {
        if (!rec.time) return "";
        const mins = Math.floor((now.getTime() - rec.time) / 60000);
        if (mins < 1) return "now";
        if (mins < 60) return mins + "m";
        if (mins < 6 * 60) return Math.floor(mins / 60) + "h";
        const d = new Date(rec.time);
        return d.toDateString() === now.toDateString()
            ? Qt.formatTime(d, "hh:mm")
            : Qt.formatDateTime(d, "d/M hh:mm");
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void { root.toggleCenter(); }
        function dnd(): void { root.dnd = !root.dnd; }
        function clear(): void { root.clearAll(); }
    }
}
