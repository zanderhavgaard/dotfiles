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
// An app replacing a notification (progress, "3 new messages", notify-send -r)
// updates its record and pops it up again.
//
// Records are only replaced (never mutated) when they change, and unchanged
// ones keep their identity, so views using ScriptModel keep their delegates
// (and popup timers) when something else changes.
//
//   qs ipc call notifications toggle   open / close the center
//   qs ipc call notifications dnd      toggle do-not-disturb
//   qs ipc call notifications clear    dismiss everything
Singleton {
    id: root

    readonly property int maxHistory: 100
    readonly property int maxPopups: 5

    property bool dnd: false
    property bool centerOpen: false
    property var popupKeys: []
    property date now: new Date()    // ticks so "5m" age labels update

    // newest first. Record:
    // { key, notif (live Notification or null), appName, summary, body, urgency, time, transient }
    property var history: []
    property int nextKey: 1

    readonly property int count: history.length
    // newest first; older ones wait their turn
    readonly property var popups: history
        .filter(r => popupKeys.includes(r.key) && r.notif !== null)
        .slice(0, maxPopups)

    // replace record `key` with a copy that has `fields` changed
    function patch(key, fields) {
        if (!history.some(r => r.key === key)) return;
        history = history.map(r => r.key === key ? Object.assign({}, r, fields) : r);
    }

    function remove(key) {
        if (history.some(r => r.key === key))
            history = history.filter(r => r.key !== key);
        removePopup(key);
    }

    function addPopup(key) {
        if (!popupKeys.includes(key)) popupKeys = popupKeys.concat([key]);
    }

    function removePopup(key) {
        if (popupKeys.includes(key)) popupKeys = popupKeys.filter(k => k !== key);
    }

    // Bodies may contain markup. Keep the harmless formatting tags and drop
    // the rest: <img src="https://..."> would make us fetch the URL, and
    // links aren't clickable here anyway (their text stays).
    function sanitize(body) {
        return (body || "").replace(/<(?!\/?(b|i|u|br)\s*\/?>)\/?[a-z][^>]*>/gi, "");
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
                body: root.sanitize(n.body),
                urgency: n.urgency,
                time: Date.now(),
                transient: n.transient,
            };
            const all = [rec].concat(root.history);
            root.history = all.slice(0, root.maxHistory);
            // pushed out of the history: nothing could dismiss these any more
            for (const old of all.slice(root.maxHistory)) {
                root.removePopup(old.key);
                if (old.notif) old.notif.dismiss();
            }
            const popUp = () => {
                if (!root.dnd || n.urgency === NotificationUrgency.Critical) root.addPopup(key);
            };
            popUp();

            // replaced by the app: refresh the record (a new object, so its
            // popup is rebuilt and its timer starts over) and show it again
            const refresh = () => {
                root.patch(key, {
                    appName: n.appName,
                    summary: n.summary,
                    body: root.sanitize(n.body),
                    time: Date.now(),
                });
                popUp();
            };
            n.summaryChanged.connect(refresh);
            n.bodyChanged.connect(refresh);

            // the app (or a timeout) closed it: keep the record, drop the
            // live object and its popup. Transient ones don't belong in history.
            n.closed.connect(reason => {
                if (rec.transient) {
                    root.remove(key);
                } else {
                    root.patch(key, { notif: null });
                    root.removePopup(key);
                }
            });
        }
    }

    // ---- actions -----------------------------------------------------------
    function hidePopup(rec) {
        removePopup(rec.key);
        // transient notifications aren't meant for the history
        if (rec.transient && rec.notif) rec.notif.expire();
    }

    function dismiss(rec) {
        remove(rec.key);
        if (rec.notif) rec.notif.dismiss();
    }

    function clearAll() {
        // empty first, so each dismiss's `closed` finds nothing left to update
        const old = history;
        history = [];
        popupKeys = [];
        for (const r of old)
            if (r.notif) r.notif.dismiss();
    }

    function toggleCenter() {
        centerOpen = !centerOpen;
        // opening the center replaces the popups
        if (centerOpen && popupKeys.length > 0) popupKeys = [];
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
