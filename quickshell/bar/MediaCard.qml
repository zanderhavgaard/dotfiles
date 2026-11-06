import QtQuick
import qs
import qs.services

// Hover card for the now-playing ring: track, artist, album, position.
HoverCard {
    id: root

    readonly property var player: Status.player

    title: "Now playing"
    aside: player ? player.identity : ""
    footer: "click: play/pause · right: next · scroll: skip"
    cardWidth: 320

    // 225 -> "3:45"
    function time(s) {
        s = Math.max(0, Math.floor(s));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    Column {
        x: Theme.inset
        width: root.cardWidth - 2 * Theme.inset
        topPadding: 4
        bottomPadding: 6
        spacing: 3

        Label {
            width: parent.width
            text: root.player ? root.player.trackTitle || "Unknown track" : ""
            font.pixelSize: 14
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
        Label {
            width: parent.width
            visible: text !== ""
            text: root.player ? root.player.trackArtist : ""
            color: Theme.fgDark
            elide: Text.ElideRight
        }
        Label {
            width: parent.width
            visible: text !== ""
            text: root.player ? root.player.trackAlbum : ""
            color: Theme.subtext
            elide: Text.ElideRight
        }

        // progress
        Item {
            visible: root.player !== null && root.player.length > 0
            width: parent.width
            height: 26

            Rectangle {
                id: track
                anchors { left: parent.left; right: parent.right; bottom: times.top; bottomMargin: 4 }
                height: 4
                radius: 2
                color: Theme.bgHighlight

                Rectangle {
                    width: root.player && root.player.length > 0
                        ? parent.width * Math.min(1, root.player.position / root.player.length) : 0
                    height: parent.height
                    radius: 2
                    color: Theme.magenta
                }
            }
            Mono {
                id: times
                anchors { left: parent.left; bottom: parent.bottom }
                text: root.player ? root.time(root.player.position) : ""
                color: Theme.subtext
                font.pixelSize: 10
            }
            Mono {
                anchors { right: parent.right; bottom: parent.bottom }
                text: root.player ? root.time(root.player.length) : ""
                color: Theme.subtext
                font.pixelSize: 10
            }
        }
    }
}
