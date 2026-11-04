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
// Auth uses /etc/pam.d/system-auth (password + faillock, the part of the
// login stack that matters for unlocking). A PAM file in a custom directory
// can't `include` the system ones: includes resolve inside that directory.
// Messages PAM sends (e.g. faillock's "account is locked ...") are shown
// instead of "wrong password". Preview attempts count towards faillock too.
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

    // what the running PAM check is for: "unlock", "preview", or "" (none /
    // aborted, so a late result is ignored). Fixed when the check starts, so
    // a check started in preview can never unlock, and vice versa.
    property string checkMode: ""
    // messages PAM sent during the current check, shown if it fails
    property string pamNote: ""

    readonly property string marker: Quickshell.env("XDG_RUNTIME_DIR") + "/quickshell-locked"

    // ---- marker --------------------------------------------------------------
    // one process at a time, re-run if the state changed meanwhile, so a fast
    // unlock + relock can't end with `rm` landing after `touch`
    property bool markerState: false
    onLockedChanged: syncMarker()

    function syncMarker() {
        if (markerProc.running) return;
        markerState = locked;
        markerProc.command = locked ? ["touch", marker] : ["rm", "-f", marker];
        markerProc.running = true;
    }

    Process {
        id: markerProc
        onExited: if (root.markerState !== root.locked) root.syncMarker()
    }

    // re-lock after a crash/restart that happened while locked
    Process {
        running: true
        command: ["test", "-e", root.marker]
        onExited: code => {
            if (code === 0) root.lock();
        }
    }

    // ---- lock / auth -----------------------------------------------------------
    function cancelCheck() {
        checkMode = "";
        if (pam.active) pam.abort();
        if (status === "checking") {
            status = "";
            statusText = "";
        }
    }

    function lock() {
        // a check that's still running (Enter, then the lid closes) must not
        // unlock what we're about to lock
        cancelCheck();
        previewing = false;
        if (locked) return;
        password = "";
        status = "";
        statusText = "";
        failures = 0;
        wallpaperProc.running = true;
        locked = true;
    }

    function submit() {
        if (pam.active || password === "") return;
        checkMode = locked ? "unlock" : previewing ? "preview" : "";
        if (checkMode === "") return;
        pamNote = "";
        status = "checking";
        statusText = "checking…";
        if (!pam.start()) {
            checkMode = "";
            password = "";
            status = "error";
            statusText = "couldn't start authentication, see journalctl --user -u quickshell";
        }
    }

    function fail(text) {
        password = "";
        failures++;
        status = "wrong";
        statusText = text;
    }

    // a PAM module that never answers shouldn't leave the lock stuck on "checking"
    Timer {
        running: root.status === "checking"
        interval: 20000
        onTriggered: {
            root.cancelCheck();
            root.password = "";
            root.status = "error";
            root.statusText = "authentication timed out, try again";
        }
    }

    PamContext {
        id: pam
        configDirectory: "/etc/pam.d"
        config: "system-auth"

        onPamMessage: {
            if (responseRequired) {
                respond(root.password);
            } else if (message !== "") {
                // e.g. faillock's "The account is locked ..." + "(10 minutes left ...)"
                root.pamNote = (root.pamNote + " " + message).trim();
                root.status = messageIsError ? "error" : "info";
                root.statusText = root.pamNote;
            }
        }

        onCompleted: result => {
            const mode = root.checkMode;
            root.checkMode = "";
            if (mode === "") return;    // aborted

            if (result === PamResult.Success) {
                root.password = "";
                root.failures = 0;
                if (mode === "unlock" && root.locked) {
                    root.status = "";
                    root.statusText = "";
                    root.locked = false;
                } else {
                    root.status = "ok";
                    root.statusText = "password accepted (preview, nothing to unlock)";
                }
            } else if (result === PamResult.Failed) {
                root.fail(root.pamNote || "wrong password");
            } else if (result === PamResult.MaxTries) {
                root.fail(root.pamNote || "too many attempts, wait a moment");
            } else {
                // the auth stack itself broke: say so instead of blaming the password
                root.password = "";
                root.status = "error";
                root.statusText = root.pamNote || "authentication error, see journalctl --user -u quickshell";
            }
        }

        onError: err => {
            root.checkMode = "";
            root.password = "";
            root.status = "error";
            root.statusText = "pam error: " + PamError.toString(err);
        }
    }

    // If the compositor refuses or drops our lock (e.g. swaylock already holds
    // it), WlSessionLock unlocks itself; follow it, so lock() works next time
    // and a stale marker doesn't lock the next quickshell start.
    Connections {
        target: sessionLock
        function onLockStateChanged() {
            if (!sessionLock.locked && root.locked) {
                root.cancelCheck();
                root.locked = false;
            }
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
            if (root.locked) return;    // never on top of (or instead of) a real lock
            root.cancelCheck();
            root.password = "";
            root.status = "";
            wallpaperProc.running = true;
            root.previewing = !root.previewing;
        }
    }
}
