import QtQuick
import qs

// One "LABEL value" pair on the right of the bar, e.g. "VOL 45".
MouseArea {
    id: root

    property string label
    property string value
    property color valueColor: Theme.fujiWhite

    signal leftClicked
    signal rightClicked
    signal scrolled(int steps)

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    // line up with taller neighbours (the clock) when placed in a Row
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: mouse => mouse.button === Qt.RightButton ? rightClicked() : leftClicked()
    onWheel: wheel => scrolled(wheel.angleDelta.y > 0 ? 1 : -1)

    Row {
        id: row
        spacing: 5

        Text {
            visible: root.label !== ""
            text: root.label
            color: Theme.mutedText
            font.family: Theme.mono
            font.pixelSize: 11
            font.letterSpacing: 0.8
            font.capitalization: Font.AllUppercase
        }
        Text {
            text: root.value
            color: root.valueColor
            font.family: Theme.mono
            font.pixelSize: 11
            font.letterSpacing: 0.8
            font.capitalization: Font.AllUppercase
        }
    }
}
