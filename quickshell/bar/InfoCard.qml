import QtQuick
import qs

// HoverCard with label / value rows and an optional footer hint.
// rows: [{ label, value, color? }]; a row with label "" draws a separator.
HoverCard {
    id: root

    property var rows: []
    property string footer: ""

    cardWidth: 340

    Repeater {
        model: root.rows

        delegate: Item {
            id: row
            required property var modelData
            readonly property bool separator: modelData.label === ""
            width: root.cardWidth
            height: separator ? 9 : 22

            Rectangle {
                visible: row.separator
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                height: 1
                color: Theme.sumiInk4
            }

            Text {
                id: label
                visible: !row.separator
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                width: 96
                text: row.modelData.label
                color: Theme.mutedText
                font.family: Theme.mono
                font.pixelSize: 10
                font.letterSpacing: 1
                font.capitalization: Font.AllUppercase
            }
            Text {
                visible: !row.separator
                anchors {
                    left: label.right
                    right: parent.right
                    rightMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideMiddle
                text: row.modelData.value ?? ""
                textFormat: Text.PlainText    // from outside: no markup
                color: row.modelData.color ?? Theme.fujiWhite
                font.family: Theme.mono
                font.pixelSize: 11
            }
        }
    }

    Text {
        visible: root.footer !== ""
        leftPadding: 14
        topPadding: 8
        text: root.footer
        color: Theme.mutedText
        font.family: Theme.mono
        font.pixelSize: 10
        font.letterSpacing: 1
        font.capitalization: Font.AllUppercase
    }
}
