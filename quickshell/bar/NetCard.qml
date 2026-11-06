import QtQuick
import Quickshell.Io
import qs
import qs.services

// Hover card for NET: connection, wifi signal/band, device, addresses.
// Read from nmcli each time the card opens (and every 5s while open).
InfoCard {
    id: root

    title: "Network"
    footer: "click: nmtui"

    Process {
        id: proc
        // `device show` for the connected device, then the wifi list, whose
        // in-use line ("*:54:5200 MHz:WPA2 WPA3") ends up under key "*"
        command: ["sh", "-c",
            "nmcli -t -f GENERAL.DEVICE,GENERAL.TYPE,GENERAL.CONNECTION,IP4.ADDRESS,IP4.GATEWAY,IP4.DNS,IP6.ADDRESS device show \"$1\";"
            + " nmcli -t -f IN-USE,SIGNAL,FREQ,SECURITY device wifi list ifname \"$1\" --rescan no 2>/dev/null",
            "sh", Status.netDevice]
        stdout: StdioCollector {
            onStreamFinished: {
                // "IP4.ADDRESS[1]:..." -> key IP4.ADDRESS, repeated keys collected
                const f = {};
                for (const line of text.split("\n")) {
                    const i = line.indexOf(":");
                    if (i < 0) continue;
                    const key = line.slice(0, i).replace(/\[\d+\]$/, "");
                    (f[key] = f[key] || []).push(line.slice(i + 1).replace(/\\:/g, ":"));
                }
                if (!f["GENERAL.DEVICE"]) {
                    root.rows = root.offline;
                    return;
                }

                const rows = [{ label: "connection", value: f["GENERAL.CONNECTION"][0] }];
                if (f["*"]) {
                    const [signal, freq, security] = f["*"][0].split(":");
                    const band = parseInt(freq) >= 5900 ? "6 GHz" : parseInt(freq) >= 4900 ? "5 GHz" : "2.4 GHz";
                    rows.push({ label: "signal", value: signal + "%",
                                color: parseInt(signal) < 40 ? Theme.yellow : Theme.fg });
                    rows.push({ label: "band", value: band + " · " + freq });
                    rows.push({ label: "security", value: security || "open",
                                color: security ? Theme.fg : Theme.yellow });
                }
                rows.push({ label: "device", value: f["GENERAL.DEVICE"][0] + " · " + f["GENERAL.TYPE"][0] });
                rows.push({ label: "" });
                for (const a of f["IP4.ADDRESS"] || []) rows.push({ label: "ipv4", value: a });
                if (f["IP4.GATEWAY"] && f["IP4.GATEWAY"][0]) rows.push({ label: "gateway", value: f["IP4.GATEWAY"][0] });
                if (f["IP4.DNS"]) rows.push({ label: "dns", value: f["IP4.DNS"].slice(0, 2).join(", ") });
                // global v6 only; link-local fe80:: isn't interesting
                const v6 = (f["IP6.ADDRESS"] || []).filter(a => !a.startsWith("fe80"));
                if (v6.length) rows.push({ label: "ipv6", value: v6[0] });
                root.rows = rows;
            }
        }
    }

    readonly property var offline: [{ label: "status", value: "disconnected", color: Theme.red }]

    Timer {
        interval: 5000
        running: root.open
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (Status.netDevice === "") root.rows = root.offline;
            else proc.running = true;
        }
    }
}
