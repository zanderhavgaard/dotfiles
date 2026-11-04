pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import QtQuick

// Everything the bar's right-hand side shows, in one place.
Singleton {
    id: root

    readonly property string scripts: Quickshell.env("HOME") + "/dotfiles/scripts"

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

    function setVolume(v) {
        if (audioReady) sink.audio.volume = Math.max(0, Math.min(1, v));
    }
    function toggleMute() {
        if (audioReady) sink.audio.muted = !sink.audio.muted;
    }
    function setMicVolume(v) {
        if (micReady) source.audio.volume = Math.max(0, Math.min(1, v));
    }
    function toggleMicMute() {
        if (micReady) source.audio.muted = !source.audio.muted;
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
        if (max > 0 && !isNaN(cur)) root.brightness = Math.round(100 * cur / max);
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

    // ---- idle inhibitor (the IdleInhibitor itself lives on a bar window) --
    property bool idleInhibited: false

    // ---- clock: English or kanji date (click the clock to switch) ---------
    property bool japaneseDate: false

    // ---- kernel -----------------------------------------------------------
    // kernelStale: the running kernel's modules are gone, i.e. linux was
    // upgraded and a reboot is pending.
    property string kernel: ""
    property bool kernelStale: false

    Process {
        id: kernelProc
        running: true
        command: ["uname", "-r"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.kernel = text.trim();
                staleProc.running = true;
            }
        }
    }

    Process {
        id: staleProc
        command: ["test", "-d", "/usr/lib/modules/" + root.kernel]
        onExited: code => root.kernelStale = code !== 0
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
    property string powerProfile: ""

    FileView {
        id: profileFile
        path: "/sys/firmware/acpi/platform_profile"
        onLoaded: root.powerProfile = text().trim()
    }

    // ---- network ----------------------------------------------------------
    property string network: ""       // connection name, "" when offline

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
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                let name = "";
                for (const line of text.split("\n")) {
                    // CONNECTION may itself contain ':' (escaped as '\:')
                    const [type, state, ...rest] = line.split(":");
                    if ((type === "wifi" || type === "ethernet") && state === "connected") {
                        name = rest.join(":").replace(/\\:/g, ":");
                        break;
                    }
                }
                root.network = name;
            }
        }
    }

    // ---- vpn (shared script with the old waybar module) -------------------
    property string vpnState: "disconnected"   // connected | connecting | disconnected
    property string vpnLabel: "off"            // netbird | mullvad | netbird+mullvad | off
    property string vpnTooltip: ""

    Process {
        id: vpnProc
        command: [root.scripts + "/vpn-status.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(text);
                    root.vpnState = j["class"];
                    root.vpnTooltip = j.tooltip;
                    const on = [];
                    if (j.text.includes("NetBird")) on.push("netbird");
                    if (j.text.includes("Mullvad")) on.push("mullvad");
                    root.vpnLabel = on.length ? on.join("+") : "off";
                } catch (e) {
                    console.warn("vpn-status:", e);
                }
            }
        }
    }

    function toggleVpn(which) {
        Quickshell.execDetached([scripts + "/vpn-status.sh", "toggle-" + which]);
        vpnRecheck.restart();
    }

    Timer {
        id: vpnRecheck
        interval: 1500
        onTriggered: vpnProc.running = true
    }

    // ---- pending updates --------------------------------------------------
    property int updates: 0
    property var updateList: []   // [{ name, from, to }]

    Process {
        id: updatesProc
        command: [root.scripts + "/updates.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(text);
                    root.updates = parseInt(j.text) || 0;
                    // checkupdates lines: "linux 7.2.14.arch1-1 -> 7.2.15.arch1-1"
                    root.updateList = root.updates === 0 ? [] : j.tooltip.split("\n")
                        .map(l => l.trim().split(/\s+/))
                        .filter(f => f.length >= 4)
                        .map(f => ({ name: f[0], from: f[1], to: f[3] }));
                } catch (e) {
                    root.updates = 0;
                    root.updateList = [];
                }
            }
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

    // ---- polling ----------------------------------------------------------
    // sysfs reads only, no processes
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            profileFile.reload();
            root.refreshBrightness();
        }
    }

    // network and VPN mostly come from `nmcli monitor`; this catches what it
    // misses (a VPN daemon reconnecting on its own) without spawning a
    // handful of processes every 5 seconds
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

    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            updatesProc.running = true;
            if (root.kernel !== "") staleProc.running = true;
        }
    }
}
