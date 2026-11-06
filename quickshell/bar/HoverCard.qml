import QtQuick
import Quickshell
import qs

// A card that pops up below a bar item while it's hovered, after a short
// delay so sweeping the mouse along the bar doesn't flash it.
//   Title ........ aside
//   (children)
//   footer hint
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

    // The window starts right at the item's bottom edge and must not overlap
    // it: the input mask isn't reliable on popups, and a window over the item
    // steals the hover, closing the card, which then reopens (flicker).
    // The card sits Theme.popupOffset down, with room around it for the shadow.
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    visible: open
    implicitWidth: cardWidth + 2 * Theme.shadowPad
    implicitHeight: card.y + card.height + Theme.shadowPad
    color: "transparent"
    mask: Region { item: card }

    Card {
        id: card
        x: Theme.shadowPad
        y: Theme.popupOffset
        width: root.cardWidth
        height: col.implicitHeight

        Column {
            id: col
            width: parent.width
            topPadding: 4
            bottomPadding: 8

            Item {
                visible: root.title !== ""
                width: parent.width
                height: 34

                Label {
                    anchors { left: parent.left; leftMargin: Theme.inset; verticalCenter: parent.verticalCenter }
                    text: root.title
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }
                Label {
                    anchors { right: parent.right; rightMargin: Theme.inset; verticalCenter: parent.verticalCenter }
                    text: root.aside
                    color: Theme.subtext
                    font.pixelSize: 11
                }
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: Theme.inset; rightMargin: Theme.inset }
                    height: 1
                    color: Theme.bgHighlight
                }
            }

            Column {
                id: body
                width: parent.width
                topPadding: 6
                bottomPadding: 4
            }

            Label {
                visible: root.footer !== ""
                leftPadding: Theme.inset
                topPadding: 4
                text: root.footer
                color: Theme.subtext
                font.pixelSize: 11
            }
        }
    }
}
