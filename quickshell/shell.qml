//@ pragma UseQApplication
// Kanagawa Wave × Paper: docked bottom bar, OSD, notifications, launcher, lock.
// Run: `qs` (config lives in ~/.config/quickshell, symlinked from dotfiles).
// IPC: `qs ipc call launcher toggle`, `qs ipc call osd brightness|media`,
//      `qs ipc call lock lock|isSecure|preview`.
// UseQApplication: tray menus are platform (QWidget) menus.
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
    // TODO: set back to false when done hacking (see the note above)
    settings.watchFiles: true

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Bar {}
        }
    }

    Osd {}
    Notifications {}
    Launcher {}
    Lock {}
}
