import QtQuick
import qs

// One bar item: an icon and/or a short value. Hoverable (a rounded
// highlight), clickable, scrollable; a HoverCard child follows containsMouse.
WheelArea {
    id: root

    property string icon
    property string text
    property color iconColor: Theme.fgDark
    property color textColor: Theme.fg

    signal leftClicked
    signal rightClicked

    implicitWidth: content.width + 14
    implicitHeight: Theme.barSize - 12
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: mouse => mouse.button === Qt.RightButton ? rightClicked() : leftClicked()

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: Theme.bgHighlight
        opacity: root.containsMouse && root.cursorShape === Qt.PointingHandCursor ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 6

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            text: root.icon
            color: root.iconColor
        }
        Mono {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
            text: root.text
            color: root.textColor
        }
    }
}
