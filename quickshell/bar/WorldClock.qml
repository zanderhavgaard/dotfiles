import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Hover card above the bar clock: UTC, Atlanta, Tokyo, Auckland.
// Times come from `date` with TZ set, so DST (Atlanta and New Zealand have
// it, Japan doesn't) follows the system tzdata instead of hand-coded offsets.
HoverCard {
    id: root

    title: "world clock"
    aside: "vs local"

    readonly property var zones: [
        { tz: "UTC", label: "utc", kanji: "" },
        { tz: "America/New_York", label: "atlanta", kanji: "" },
        { tz: "Asia/Tokyo", label: "tokyo", kanji: "東京" },
        { tz: "Pacific/Auckland", label: "auckland", kanji: "" },
    ]

    property var rows: []

    // "+0900" -> 540
    function minutes(z) {
        const sign = z[0] === "-" ? -1 : 1;
        return sign * (parseInt(z.slice(1, 3)) * 60 + parseInt(z.slice(3, 5)));
    }

    // 540 -> "+9h", -330 -> "−5h30"
    function offsetLabel(m) {
        if (m === 0) return "±0h";
        const sign = m > 0 ? "+" : "−";
        const a = Math.abs(m);
        return sign + Math.floor(a / 60) + "h" + (a % 60 ? String(a % 60).padStart(2, "0") : "");
    }

    Process {
        id: proc
        // one line per zone, then local last: tz|HH:MM|Tue 3 Nov|+0900
        command: ["sh", "-c",
            "for tz in \"$@\"; do TZ=$tz date \"+$tz|%H:%M|%a %-d %b|%z\"; done; date '+local|%H:%M|%a %-d %b|%z'",
            "sh"].concat(root.zones.map(z => z.tz))
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n").map(l => l.split("|"));
                const local = lines.find(l => l[0] === "local");
                if (!local) return;
                const localMin = root.minutes(local[3]);
                root.rows = root.zones.map(z => {
                    const l = lines.find(x => x[0] === z.tz);
                    if (!l) return null;
                    return {
                        label: z.label,
                        kanji: z.kanji,
                        time: l[1],
                        date: l[2],
                        otherDay: l[2] !== local[2],
                        offset: root.offsetLabel(root.minutes(l[3]) - localMin),
                    };
                }).filter(r => r !== null);
            }
        }
    }

    Timer {
        interval: 30000
        running: root.open
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Repeater {
        model: root.rows

        delegate: Item {
            id: row
            required property var modelData
            width: root.cardWidth
            height: 40

            // city
            Row {
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                spacing: 6

                Text {
                    id: city
                    text: row.modelData.label
                    color: Theme.oldWhite
                    font.family: Theme.mono
                    font.pixelSize: 11
                    font.letterSpacing: 1
                    font.capitalization: Font.AllUppercase
                }
                Text {
                    visible: text !== ""
                    anchors.baseline: city.baseline
                    text: row.modelData.kanji
                    color: Theme.mutedText
                    font.family: Theme.serif
                    font.pixelSize: 12
                }
            }

            // time + date
            Column {
                anchors { left: parent.left; leftMargin: 130; verticalCenter: parent.verticalCenter }

                Text {
                    text: row.modelData.time
                    color: Theme.fujiWhite
                    font.family: Theme.mono
                    font.pixelSize: 16
                    font.weight: Font.Medium
                }
                Text {
                    // yellow when it's already tomorrow / still yesterday there
                    text: row.modelData.date
                    color: row.modelData.otherDay ? Theme.carpYellow : Theme.mutedText
                    font.family: Theme.mono
                    font.pixelSize: 10
                }
            }

            Text {
                anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                text: row.modelData.offset
                color: Theme.mutedText
                font.family: Theme.mono
                font.pixelSize: 11
            }
        }
    }
}
