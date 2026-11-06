// Tokyo Night, refined: floating top bar, OSD, notifications, launcher, lock.
// Run: `qs` (config lives in ~/.config/quickshell, symlinked from dotfiles).
// IPC: `qs ipc show` lists every target and function (launcher, osd,
//      notifications, lock).
//
// Auto-reload is off: a reload while the session is locked might release the
// lock before it's re-taken. After editing, run:
//   systemctl --user restart quickshell
// (a restart is safe while locked: niri keeps an abandoned lock locked and
// lock/Lock.qml re-locks on start)
import Quickshell
import QtQuick
import qs.bar
import qs.osd
import qs.notifs
import qs.launcher
import qs.lock

ShellRoot {
    settings.watchFiles: false

    Variants {
        model: Quickshell.screens

        Bar {}
    }

    Osd {}
    Notifications {}
    Launcher {}
    Lock {}
}
