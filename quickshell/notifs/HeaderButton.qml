import QtQuick
import qs

// Small text button for the notification center header.
Text {
    id: hb
    property bool highlight: false
    signal activated
    color: highlight ? Theme.carpYellow : hbArea.containsMouse ? Theme.fujiWhite : Theme.mutedText
    font.family: Theme.mono
    font.pixelSize: 11
    font.letterSpacing: 1
    font.capitalization: Font.AllUppercase
    MouseArea {
        id: hbArea
        anchors.fill: parent
        anchors.margins: -6
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: hb.activated()
    }
}
