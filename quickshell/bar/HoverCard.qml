import QtQuick
import Quickshell
import qs

// A card that pops up above a bar item while it's hovered, after a short
// delay so sweeping the mouse along the bar doesn't flash it.
//   TITLE ........ ASIDE
//   (children)
//   FOOTER HINT
PopupWindow {
    id: root

    required property MouseArea anchorItem   // needs hoverEnabled
    property string title
    property string aside
    property string footer
    property int cardWidth: 300

    default property alias content: body.data

    readonly property bool hovered: anchorItem.containsMouse
    property bool open: false
    onHoveredChanged: hovered ? showDelay.restart() : (showDelay.stop(), open = false)

    Timer {
        id: showDelay
        interval: 250
        onTriggered: root.open = true
    }

    anchor.item: anchorItem
    anchor.edges: Edges.Top
    anchor.gravity: Edges.Top
    visible: open
    implicitWidth: cardWidth
    implicitHeight: card.height + 8   // 8px of air between card and bar
    color: "transparent"

    Rectangle {
        id: card
        width: parent.width
        height: col.implicitHeight
        color: Theme.sumiInk0
        border.width: 1
        border.color: Theme.sumiInk6

        Column {
            id: col
            width: parent.width

            Item {
                width: parent.width
                height: 28

                Caps {
                    anchors { left: parent.left; leftMargin: Theme.inset; verticalCenter: parent.verticalCenter }
                    text: root.title
                }
                Caps {
                    anchors { right: parent.right; rightMargin: Theme.inset; verticalCenter: parent.verticalCenter }
                    text: root.aside
                }
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 1 }
                    height: 1
                    color: Theme.sumiInk4
                }
            }

            Column {
                id: body
                width: parent.width
                topPadding: 6
                bottomPadding: 8
            }

            Caps {
                visible: root.footer !== ""
                leftPadding: Theme.inset
                bottomPadding: 8
                text: root.footer
            }
        }
    }
}
