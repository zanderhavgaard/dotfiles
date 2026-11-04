import QtQuick
import Quickshell.Io
import qs

// Hover card for NET: connection, wifi signal/band, device, addresses.
// Read from nmcli each time the card opens (and every 5s while open).
InfoCard {
    id: root

    title: "network"
    footer: "click: nmtui"

    // Prints `nmcli -t device show` for the first connected wifi/ethernet
    // device, plus a "WIFI:<signal>:<freq>:<security>" line when it's wifi.
    readonly property string script: "
        dev=$(nmcli -t -f DEVICE,TYPE,STATE device \
            | awk -F: '($2==\"wifi\"||$2==\"ethernet\") && $3==\"connected\" {print $1; exit}')
        [ -z \"$dev\" ] && exit 0
        nmcli -t -f GENERAL.DEVICE,GENERAL.TYPE,GENERAL.CONNECTION,IP4.ADDRESS,IP4.GATEWAY,IP4.DNS,IP6.ADDRESS device show \"$dev\"
        nmcli -t -f IN-USE,SIGNAL,FREQ,SECURITY device wifi list ifname \"$dev\" --rescan no \
            | awk -F: '$1==\"*\" {print \"WIFI:\" $2 \":\" $3 \":\" $4; exit}'
    "

    Process {
        id: proc
        command: ["sh", "-c", root.script]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = {};
                for (const line of text.split("\n")) {
                    const i = line.indexOf(":");
                    if (i < 0) continue;
                    // "IP4.ADDRESS[1]:..." -> key IP4.ADDRESS, repeated keys collected
                    const key = line.slice(0, i).replace(/\[\d+\]$/, "");
                    (f[key] = f[key] || []).push(line.slice(i + 1).replace(/\\:/g, ":"));
                }

                if (!f["GENERAL.DEVICE"]) {
                    root.rows = [{ label: "status", value: "disconnected", color: Theme.waveRed }];
                    return;
                }

                const rows = [{ label: "connection", value: f["GENERAL.CONNECTION"][0] }];
                if (f.WIFI) {
                    const [signal, freq, security] = f.WIFI[0].split(":");
                    const band = parseInt(freq) >= 5900 ? "6 GHz" : parseInt(freq) >= 4900 ? "5 GHz" : "2.4 GHz";
                    rows.push({ label: "signal", value: signal + "%",
                                color: parseInt(signal) < 40 ? Theme.carpYellow : Theme.fujiWhite });
                    rows.push({ label: "band", value: band + " · " + freq });
                    rows.push({ label: "security", value: security || "open",
                                color: security ? Theme.fujiWhite : Theme.carpYellow });
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

    Timer {
        interval: 5000
        running: root.open
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }
}
