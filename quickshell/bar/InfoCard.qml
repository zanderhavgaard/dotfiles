import QtQuick
import qs

// HoverCard with label / value rows.
// rows: [{ label, value, color? }]; a row with label "" draws a separator.
HoverCard {
    id: root

    property var rows: []

    cardWidth: 340

    Repeater {
        model: root.rows

        delegate: Item {
            id: row
            required property var modelData
            readonly property bool separator: modelData.label === ""
            width: root.cardWidth
            height: separator ? 11 : 23

            Rectangle {
                visible: row.separator
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                anchors.leftMargin: Theme.inset
                anchors.rightMargin: Theme.inset
                height: 1
                color: Theme.bgHighlight
            }

            Label {
                id: label
                visible: !row.separator
                color: Theme.subtext
                anchors { left: parent.left; leftMargin: Theme.inset; verticalCenter: parent.verticalCenter }
                width: 96
                text: row.modelData.label
            }
            Mono {
                visible: !row.separator
                anchors {
                    left: label.right
                    right: parent.right
                    rightMargin: Theme.inset
                    verticalCenter: parent.verticalCenter
                }
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideMiddle
                text: row.modelData.value ?? ""
                color: row.modelData.color ?? Theme.fg
            }
        }
    }
}
