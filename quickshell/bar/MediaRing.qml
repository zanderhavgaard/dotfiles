import QtQuick
import QtQuick.Shapes
import qs
import qs.services

// Now playing: a ring that fills with the track's progress around a
// play/pause glyph. Click: play/pause, right-click: next, scroll: skip.
// Only there while a player is.
WheelArea {
    id: root

    readonly property var player: Status.player
    readonly property real progress: player && player.length > 0
        ? Math.max(0, Math.min(1, player.position / player.length)) : 0

    visible: player !== null
    implicitWidth: 30
    implicitHeight: 30
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            if (player.canGoNext) player.next();
        } else if (player.canTogglePlaying) {
            player.togglePlaying();
        }
    }
    onScrolled: steps => {
        if (steps < 0 && player.canGoNext) player.next();
        else if (steps > 0 && player.canGoPrevious) player.previous();
    }

    // MPRIS doesn't push position updates; ask for them while playing
    Timer {
        running: root.player !== null && root.player.isPlaying
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: Theme.bgHighlight
            strokeWidth: 2.5
            fillColor: "transparent"
            PathAngleArc { centerX: 15; centerY: 15; radiusX: 12; radiusY: 12; startAngle: 0; sweepAngle: 360 }
        }
        ShapePath {
            strokeColor: Theme.magenta
            strokeWidth: 2.5
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: 15; centerY: 15; radiusX: 12; radiusY: 12; startAngle: -90; sweepAngle: 360 * root.progress }
        }
    }

    Icon {
        anchors.centerIn: parent
        text: root.player && root.player.isPlaying ? Theme.glyph.pause : Theme.glyph.play
        color: root.containsMouse ? Theme.fg : Theme.magenta
        font.pixelSize: 13
    }

    MediaCard { anchorItem: root }
}
