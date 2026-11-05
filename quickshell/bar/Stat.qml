import QtQuick
import qs

// One "LABEL value" pair on the bar, e.g. "VOL 45". Hoverable, so a
// HoverCard child can follow containsMouse.
WheelArea {
    id: root

    property string label
    property string value
    property color valueColor: Theme.fujiWhite

    signal leftClicked
    signal rightClicked

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: mouse => mouse.button === Qt.RightButton ? rightClicked() : leftClicked()

    Row {
        id: row
        spacing: 5

        Caps {
            visible: root.label !== ""
            text: root.label
            font.pixelSize: 11
            font.letterSpacing: 0.8
        }
        Caps {
            text: root.value
            color: root.valueColor
            font.pixelSize: 11
            font.letterSpacing: 0.8
        }
    }
}
