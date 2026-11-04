import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower
import qs
import qs.services

// Hover card for BAT: charge, state, time left, power draw, profile, health.
InfoCard {
    id: root

    title: "battery"

    // the physical battery (BAT1), not UPower's combined display device,
    // so model / health / cycle count are available
    readonly property var dev: UPower.devices.values.find(d => d.isLaptopBattery && d.nativePath !== "")
        ?? UPower.displayDevice

    FileView {
        id: cycles
        path: root.dev && root.dev.nativePath !== "" ? "/sys/class/power_supply/" + root.dev.nativePath + "/cycle_count" : ""
        printErrors: false
    }

    // seconds -> "3h 12m"
    function duration(s) {
        if (!s || s <= 0) return "";
        const h = Math.floor(s / 3600), m = Math.round((s % 3600) / 60);
        return (h > 0 ? h + "h " : "") + m + "m";
    }

    function stateText(st) {
        switch (st) {
        case UPowerDeviceState.Charging: return "charging";
        case UPowerDeviceState.Discharging: return "on battery";
        case UPowerDeviceState.FullyCharged: return "full";
        case UPowerDeviceState.PendingCharge: return "plugged in, not charging";
        case UPowerDeviceState.Empty: return "empty";
        default: return "unknown";
        }
    }

    rows: {
        if (!dev) return [{ label: "battery", value: "none" }];
        const pct = dev.energyCapacity > 0 ? Math.round(100 * dev.energy / dev.energyCapacity) : 0;
        const rows = [
            { label: "charge", value: pct + "% · " + dev.energy.toFixed(1) + " / " + dev.energyCapacity.toFixed(1) + " Wh",
              color: pct <= 15 ? Theme.waveRed : pct <= 30 ? Theme.carpYellow : Theme.fujiWhite },
            { label: "state", value: stateText(dev.state) },
        ];
        if (dev.state === UPowerDeviceState.Discharging && duration(dev.timeToEmpty))
            rows.push({ label: "time left", value: duration(dev.timeToEmpty) });
        if (dev.state === UPowerDeviceState.Charging && duration(dev.timeToFull))
            rows.push({ label: "until full", value: duration(dev.timeToFull) });
        if (Math.abs(dev.changeRate) > 0.05)
            rows.push({ label: dev.state === UPowerDeviceState.Charging ? "charge rate" : "draw",
                        value: Math.abs(dev.changeRate).toFixed(1) + " W" });
        if (Status.powerProfile !== "")
            rows.push({ label: "profile", value: Status.powerProfile });
        rows.push({ label: "" });
        if (dev.healthSupported)
            rows.push({ label: "health", value: Math.round(dev.healthPercentage) + "%",
                        color: dev.healthPercentage < 70 ? Theme.carpYellow : Theme.fujiWhite });
        const c = parseInt(cycles.text());
        if (!isNaN(c)) rows.push({ label: "cycles", value: String(c) });
        if (dev.model) rows.push({ label: "model", value: dev.model });
        return rows;
    }
}
