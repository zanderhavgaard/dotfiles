import QtQuick
import Quickshell.Io
import qs

// Hover card for VPN: NetBird and Mullvad side by side.
// Read from `netbird status --json` and `mullvad status -j` when the card
// opens (and every 5s while open).
InfoCard {
    id: root

    title: "vpn"
    footer: "click: netbird · right-click: mullvad"

    Process {
        id: proc
        command: ["sh", "-c",
            "netbird status --json 2>/dev/null || echo '{}'; echo; echo ---; mullvad status -j 2>/dev/null || echo '{}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [nbText, mvText] = text.split("\n---");
                let nb = {}, mv = {};
                try { nb = JSON.parse(nbText); } catch (e) {}
                try { mv = JSON.parse(mvText); } catch (e) {}
                root.rows = root.netbirdRows(nb).concat([{ label: "" }], root.mullvadRows(mv));
            }
        }
    }

    function stateColor(state) {
        return state === "connected" ? Theme.springGreen
            : state === "connecting" ? Theme.carpYellow
            : Theme.fujiGray;
    }

    function netbirdRows(nb) {
        if (!nb.management) return [{ label: "netbird", value: "not running", color: Theme.fujiGray }];
        const state = nb.management.connected ? "connected" : String(nb.daemonStatus || "off").toLowerCase();
        const rows = [{ label: "netbird", value: state, color: stateColor(state) }];
        if (nb.management.connected) {
            if (nb.netbirdIp) rows.push({ label: "address", value: nb.netbirdIp });
            if (nb.fqdn) rows.push({ label: "name", value: nb.fqdn });
            rows.push({ label: "peers", value: nb.peers.connected + " / " + nb.peers.total + " connected" });
        }
        if (nb.management.url) rows.push({ label: "management", value: nb.management.url.replace(/^https?:\/\//, "").replace(/:443$/, "") });
        return rows;
    }

    function mullvadRows(mv) {
        if (!mv.state) return [{ label: "mullvad", value: "not running", color: Theme.fujiGray }];
        const rows = [{ label: "mullvad", value: mv.state, color: stateColor(mv.state) }];
        const loc = (mv.details && mv.details.location) || {};
        const place = [loc.city, loc.country].filter(x => x).join(", ");
        if (mv.state === "connected") {
            if (loc.hostname) rows.push({ label: "relay", value: loc.hostname });
            if (place) rows.push({ label: "exit", value: place });
            if (loc.ipv4) rows.push({ label: "exit ip", value: loc.ipv4 });
        } else {
            // when disconnected, mullvad reports where you appear from without it
            if (place) rows.push({ label: "location", value: place });
            if (loc.ipv4) rows.push({ label: "public ip", value: loc.ipv4 });
        }
        if (mv.details && mv.details.locked_down)
            rows.push({ label: "lockdown", value: "on: traffic blocked when off", color: Theme.carpYellow });
        return rows;
    }

    Timer {
        interval: 5000
        running: root.open
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }
}
