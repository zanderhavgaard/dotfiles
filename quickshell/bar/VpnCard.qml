import QtQuick
import qs
import qs.services

// Hover card for VPN: NetBird and Mullvad, from the status Status keeps
// (refreshed when the card opens).
InfoCard {
    id: root

    title: "vpn"
    footer: "click: netbird · right-click: mullvad"

    onOpenChanged: if (open) Status.refreshVpn()

    rows: netbirdRows(Status.netbird).concat([{ label: "" }], mullvadRows(Status.mullvad))

    function netbirdRows(nb) {
        if (!nb.management) return [{ label: "netbird", value: "not running", color: Theme.fujiGray }];
        const state = Status.netbirdState;
        const rows = [{ label: "netbird", value: state, color: Theme.stateColor(state) }];
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
        const rows = [{ label: "mullvad", value: mv.state, color: Theme.stateColor(mv.state) }];
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
}
