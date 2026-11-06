import QtQuick
import Quickshell.Services.Pipewire
import qs

// Hover card for VOL (a sink) or MIC (a source): the device, its level, and
// the apps connected to it right now, i.e. what's playing, or what's
// listening to the mic.
InfoCard {
    id: root

    required property PwNode node
    property bool input: false   // true for the mic

    title: input ? "Microphone" : "Output"
    cardWidth: 390   // fits the footer hint and long device names

    // links into a sink come from playback streams; links out of a
    // source go to capture streams
    PwNodeLinkTracker {
        id: links
        node: root.node
    }

    readonly property var streams: links.linkGroups
        .map(g => root.input ? g.target : g.source)
        .filter(n => n && n.isStream)

    // bind the streams so their names and volumes are live
    PwObjectTracker {
        objects: root.streams
    }

    function appName(n) {
        const p = n.properties || {};
        return p["application.name"] || n.description || n.nickname || n.name || "unknown";
    }

    rows: {
        if (!node || !node.audio) return [{ label: "device", value: "none", color: Theme.subtext }];
        const muted = node.audio.muted;
        const rows = [
            { label: "device", value: node.description || node.nickname || node.name },
            { label: input ? "level" : "volume", value: Math.round(node.audio.volume * 100) + "%" },
            { label: "state", value: muted ? "muted" : (input ? "live" : "on"),
              color: muted ? Theme.subtext : (input ? Theme.yellow : Theme.fg) },
            { label: "" },
        ];
        if (streams.length === 0) {
            rows.push({ label: input ? "listening" : "playing", value: "nothing", color: Theme.subtext });
        } else {
            // de-duplicate apps with several streams (browsers do this)
            const seen = {};
            for (const s of streams) {
                const name = appName(s);
                if (seen[name]) continue;
                seen[name] = true;
                rows.push({
                    label: input ? "listening" : "playing",
                    value: name + (!input && s.audio ? " · " + Math.round(s.audio.volume * 100) + "%" : ""),
                    color: input ? Theme.yellow : Theme.fg,
                });
            }
        }
        return rows;
    }

    footer: input ? "click: mute · right: pwvucontrol · scroll: level"
                  : "click: pwvucontrol · right: mute · scroll: volume"
}
