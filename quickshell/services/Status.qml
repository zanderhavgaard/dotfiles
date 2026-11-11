pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import QtQuick

// System state for the bars and their hover cards: audio, media, brightness,
// battery, power profile, network, VPN, kernel, pending updates, plus the UI
// toggles shared between bars (idle inhibitor, date language).
Singleton {
    id: root

    readonly property string scripts: Quickshell.env("HOME") + "/dotfiles/scripts"

    // run a command in a terminal window
    function inTerminal(cmd) {
        Quickshell.execDetached(["ghostty", "-e"].concat(cmd));
    }

    // ---- audio ------------------------------------------------------------
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool audioReady: sink !== null && sink.audio !== null
    readonly property real volume: audioReady ? sink.audio.volume : 0
    readonly property bool muted: audioReady && sink.audio.muted

    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool micReady: source !== null && source.audio !== null
    readonly property real micVolume: micReady ? source.audio.volume : 0
    readonly property bool micMuted: micReady && source.audio.muted

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    // for the sink or the source; 5% per step
    function stepVolume(node, steps) {
        if (node && node.audio)
            node.audio.volume = Math.max(0, Math.min(1, node.audio.volume + steps * 0.05));
    }
    function toggleMuted(node) {
        if (node && node.audio) node.audio.muted = !node.audio.muted;
    }

    // ---- media ------------------------------------------------------------
    // the player to report on: whichever is playing, else the first one
    // (playerctld is a proxy that mirrors another player; skipped)
    readonly property MprisPlayer player: {
        const ps = Mpris.players.values.filter(p => !p.dbusName.includes("playerctld"));
        return ps.find(p => p.isPlaying) ?? ps[0] ?? null;
    }

    // ---- screen brightness ----------------------------------------------
    // Read straight from sysfs (no process per poll). sysfs has no change
    // notification we can watch, so it's polled, and refreshed right away
    // when niri's brightness keys call `qs ipc call osd brightness`.
    property int brightness: -1   // percent, -1 until first read / no backlight
    property string backlight: "" // e.g. /sys/class/backlight/amdgpu_bl1

    Process {
        running: true
        command: ["sh", "-c", "ls -d /sys/class/backlight/* | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: root.backlight = text.trim()
        }
    }

    FileView {
        id: maxBrightnessFile
        path: root.backlight !== "" ? root.backlight + "/max_brightness" : ""
        onLoaded: root.updateBrightness()
    }
    FileView {
        id: brightnessFile
        path: root.backlight !== "" ? root.backlight + "/brightness" : ""
        onLoaded: root.updateBrightness()
    }

    function updateBrightness() {
        const max = parseInt(maxBrightnessFile.text());
        const cur = parseInt(brightnessFile.text());
        if (max > 0 && !isNaN(cur)) brightness = Math.round(100 * cur / max);
    }

    function refreshBrightness() {
        if (backlight !== "") brightnessFile.reload();
    }

    function stepBrightness(steps) {
        Quickshell.execDetached(["brightnessctl", "--class=backlight", "set",
            Math.abs(steps * 5) + "%" + (steps > 0 ? "+" : "-")]);
        brightnessRecheck.restart();
    }

    Timer {
        id: brightnessRecheck
        interval: 100
        onTriggered: root.refreshBrightness()
    }

    // ---- battery ----------------------------------------------------------
    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery !== null && battery.isLaptopBattery
    readonly property int batteryPercent: hasBattery && battery.energyCapacity > 0
        ? Math.round(100 * battery.energy / battery.energyCapacity) : 0
    readonly property bool charging: hasBattery
        && (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.FullyCharged
            || battery.state === UPowerDeviceState.PendingCharge)

    // ---- power profile (TLP sets the ACPI platform profile) --------------
    readonly property string powerProfile: profileFile.text().trim()

    FileView {
        id: profileFile
        path: "/sys/firmware/acpi/platform_profile"
    }

    // brightness and profile: sysfs reads only, no processes
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            profileFile.reload();
            root.refreshBrightness();
        }
    }

    // ---- UI toggles ---------------------------------------------------------
    // the IdleInhibitor lives on the primary bar; deliberately not remembered,
    // so a restart can't leave the screen kept awake
    property bool idleInhibited: false

    // click the clock to switch; remembered in ~/.local/state/quickshell/.../ui.json
    property alias japaneseDate: ui.japaneseDate

    FileView {
        path: Quickshell.statePath("ui.json")
        blockLoading: true
        printErrors: false   // missing on first run
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: ui
            property bool japaneseDate: false
        }
    }

    // ---- network ----------------------------------------------------------
    property string network: ""       // connection name, "" when offline
    property string netDevice: ""     // e.g. wlan0, "" when offline

    // `nmcli monitor` prints a line on every NetworkManager change; re-read
    // the state (and the VPNs, whose tunnels show up there too) when it does,
    // instead of polling. It's restarted if it exits.
    Process {
        id: netMonitor
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: netRecheck.restart()
        }
        onExited: netMonitorRestart.restart()
    }

    Timer {
        id: netMonitorRestart
        interval: 5000
        onTriggered: netMonitor.running = true
    }

    // changes come in bursts: settle first
    Timer {
        id: netRecheck
        interval: 500
        onTriggered: {
            netProc.running = true;
            vpnProc.running = true;
        }
    }

    Process {
        id: netProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,DEVICE,CONNECTION", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                let name = "", dev = "";
                for (const line of text.split("\n")) {
                    // CONNECTION may itself contain ':' (escaped as '\:')
                    const [type, state, device, ...rest] = line.split(":");
                    if ((type === "wifi" || type === "ethernet") && state === "connected") {
                        name = rest.join(":").replace(/\\:/g, ":");
                        dev = device;
                        break;
                    }
                }
                root.network = name;
                root.netDevice = dev;
            }
        }
    }

    // network and VPN mostly come from `nmcli monitor`; this catches what it
    // misses (a VPN daemon reconnecting on its own)
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            vpnProc.running = true;
            netProc.running = true;
        }
    }

    // ---- vpn: NetBird + Mullvad --------------------------------------------
    // Raw status JSON from both CLIs ({} when a daemon isn't running); the bar
    // and VpnCard derive everything from these.
    property var netbird: ({})
    property var mullvad: ({})

    // connected | connecting | disconnecting | off | (netbird's daemon status)
    readonly property string netbirdState: !netbird.management ? "off"
        : netbird.management.connected ? "connected"
        : String(netbird.daemonStatus || "off").toLowerCase()
    readonly property string mullvadState: mullvad.state || "off"

    function busy(state) {
        return state === "connecting" || state === "disconnecting";
    }

    // overall: connected | connecting | disconnected
    readonly property string vpnState: netbirdState === "connected" || mullvadState === "connected" ? "connected"
        : busy(netbirdState) || busy(mullvadState) ? "connecting"
        : "disconnected"
    // netbird | mullvad | netbird+mullvad | off
    readonly property string vpnLabel: {
        const on = [];
        if (netbirdState === "connected" || busy(netbirdState)) on.push("netbird");
        if (mullvadState === "connected" || busy(mullvadState)) on.push("mullvad");
        return on.length ? on.join("+") : "off";
    }

    function refreshVpn() {
        vpnProc.running = true;
    }

    Process {
        id: vpnProc
        command: ["sh", "-c",
            // (echo: the JSON has no trailing newline)
            "netbird status --json 2>/dev/null || echo '{}'; echo; echo ---; mullvad status -j 2>/dev/null || echo '{}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [nb, mv] = text.split("\n---");
                try { root.netbird = JSON.parse(nb); } catch (e) { root.netbird = {}; }
                try { root.mullvad = JSON.parse(mv); } catch (e) { root.mullvad = {}; }
            }
        }
    }

    // the script works out up/down (shared with the old waybar module)
    function toggleVpn(which) {
        Quickshell.execDetached([scripts + "/vpn-status.sh", "toggle-" + which]);
        vpnRecheck.restart();
    }

    Timer {
        id: vpnRecheck
        interval: 1500
        onTriggered: vpnProc.running = true
    }

    // ---- kernel -----------------------------------------------------------
    // kernelStale: the running kernel's modules are gone, i.e. linux was
    // upgraded and a reboot is pending.
    readonly property string kernel: osrelease.text().trim()
    property bool kernelStale: false

    FileView {
        id: osrelease
        path: "/proc/sys/kernel/osrelease"
        blockLoading: true
    }

    Process {
        id: staleProc
        command: ["test", "-d", "/usr/lib/modules/" + root.kernel]
        onExited: code => root.kernelStale = code !== 0
    }

    // ---- pending updates --------------------------------------------------
    property var updateList: []   // [{ name, from, to }]
    readonly property int updates: updateList.length

    Process {
        id: updatesProc
        // repo: checkupdates syncs a private copy of the db, never touches the real one
        // aur:  paru -Qua queries the AUR RPC for installed foreign packages
        command: ["sh", "-c", "checkupdates; paru -Qua"]
        stdout: StdioCollector {
            // both print "linux 7.2.14.arch1-1 -> 7.2.15.arch1-1"
            onStreamFinished: root.updateList = text.split("\n")
                .map(l => l.trim().split(/\s+/))
                .filter(f => f.length >= 4)
                .map(f => ({ name: f[0], from: f[1], to: f[3] }))
        }
    }

    // opens paru in a terminal; recount once the window closes
    Process {
        id: paruProc
        command: ["ghostty", "-e", "paru"]
        onExited: {
            updatesProc.running = true;
            staleProc.running = true;
        }
    }

    function runUpdates() {
        paruProc.running = true;
    }

    Timer {
        interval: 10 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            updatesProc.running = true;
            staleProc.running = true;
        }
    }
}
