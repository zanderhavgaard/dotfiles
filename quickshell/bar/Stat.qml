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
    // one step per mouse-wheel notch (120); a touchpad's many small deltas
    // add up to the same, instead of each counting as a full step
    property real wheelAccum: 0
    onWheel: wheel => {
        wheelAccum += wheel.angleDelta.y;
        const steps = wheelAccum > 0 ? Math.floor(wheelAccum / 120) : Math.ceil(wheelAccum / 120);
        if (steps === 0) return;
        wheelAccum -= steps * 120;
        scrolled(steps);
    }

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
            textFormat: Text.PlainText    // from outside: no markup
            color: root.valueColor
            font.family: Theme.mono
            font.pixelSize: 11
            font.letterSpacing: 0.8
            font.capitalization: Font.AllUppercase
        }
    }
}
