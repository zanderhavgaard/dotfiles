import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import qs

// Session lock (ext-session-lock) with PAM auth.
//
//   qs ipc call lock lock       lock now (scripts/lock.sh wraps this)
//   qs ipc call lock isSecure   true once the compositor confirms the lock
//   qs ipc call lock preview    the same UI as a plain overlay, Esc closes.
//                               Nothing is locked, but the password IS checked,
//                               so auth can be tested without risk.
//
// Auth uses /etc/pam.d/login, the same stack swaylock uses. (A PAM file in
// a custom directory can't `include login`: includes resolve inside that
// directory, so every attempt fails before the password is even checked.)
//
// While locked, $XDG_RUNTIME_DIR/quickshell-locked exists. If quickshell
// crashes, systemd restarts it, it sees the marker and locks again, so
// there's always a lock screen to type the password into.
//
// Last resort from a TTY (Ctrl+Alt+F2): stop quickshell, then let swaylock
// take over the abandoned lock and unlock it:
//   systemctl --user stop quickshell
//   WAYLAND_DISPLAY=wayland-1 swaylock
// then, once unlocked (otherwise the marker makes it lock again on start):
//   rm -f $XDG_RUNTIME_DIR/quickshell-locked; systemctl --user start quickshell
Scope {
    id: root

    // state shared by every screen's surface
    property bool locked: false
    property bool previewing: false
    property string password: ""
    property string status: ""      // "" | checking | wrong | error | info | ok
    property string statusText: ""
    property int failures: 0
    property string wallpaper: ""

    readonly property string marker: Quickshell.env("XDG_RUNTIME_DIR") + "/quickshell-locked"

    onLockedChanged: Quickshell.execDetached(locked ? ["touch", marker] : ["rm", "-f", marker])

    // re-lock after a crash/restart that happened while locked
    Process {
        running: true
        command: ["test", "-e", root.marker]
        onExited: code => {
            if (code === 0) root.lock();
        }
    }

    function lock() {
        if (locked) return;
        password = "";
        status = "";
        failures = 0;
        wallpaperProc.running = true;
        locked = true;
    }

    function submit() {
        if (pam.active || password === "") return;
        status = "checking";
        statusText = "checking…";
        pam.start();
    }

    function fail(text) {
        password = "";
        failures++;
        status = "wrong";
        statusText = text;
    }

    PamContext {
        id: pam
        configDirectory: "/etc/pam.d"
        config: "login"

        onPamMessage: {
            if (responseRequired) {
                respond(root.password);
            } else if (message !== "") {
                // e.g. fingerprint prompts or account warnings
                root.status = messageIsError ? "error" : "info";
                root.statusText = message;
            }
        }

        onCompleted: result => {
            if (result === PamResult.Success && root.previewing) {
                root.password = "";
                root.status = "ok";
                root.statusText = "password accepted (preview, nothing to unlock)";
            } else if (result === PamResult.Success) {
                root.password = "";
                root.status = "";
                root.failures = 0;
                root.locked = false;
            } else if (result === PamResult.Failed) {
                root.fail("wrong password");
            } else if (result === PamResult.MaxTries) {
                root.fail("too many attempts, wait a moment");
            } else {
                // the auth stack itself broke: say so instead of blaming the password
                root.password = "";
                root.status = "error";
                root.statusText = "authentication error, see journalctl --user -u quickshell";
            }
        }

        onError: err => {
            root.password = "";
            root.status = "error";
            root.statusText = "pam error: " + PamError.toString(err);
        }
    }

    WlSessionLock {
        id: sessionLock
        locked: root.locked

        WlSessionLockSurface {
            color: Theme.sumiInk0

            LockSurface {
                anchors.fill: parent
                lock: root
            }
        }
    }

    // preview: same surface in an overlay, so the design can be checked
    // without locking anything
    LazyLoader {
        active: root.previewing

        PanelWindow {
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore
            color: Theme.sumiInk0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "qs-lock-preview"

            LockSurface {
                anchors.fill: parent
                lock: root
                preview: true
            }
        }
    }

    // current awww wallpaper, e.g.
    // ": eDP-1: 1440x960, scale: 2, currently displaying: image: /path/to.jpg"
    Process {
        id: wallpaperProc
        running: true
        command: ["awww", "query"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = text.match(/image: (.+)$/m);
                if (m) root.wallpaper = m[1].trim();
            }
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void { root.lock(); }
        function isSecure(): bool { return sessionLock.secure; }
        function preview(): void {
            root.password = "";
            root.status = "";
            wallpaperProc.running = true;
            root.previewing = !root.previewing;
        }
    }
}
