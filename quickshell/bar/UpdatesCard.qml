import QtQuick
import qs
import qs.services

// Hover card above the ↑N update count: package, old → new version.
// Kernel packages are yellow, since they mean a reboot afterwards.
HoverCard {
    id: root

    title: "Updates"
    aside: Status.updates + " pending"
    footer: "click to update with paru"
    cardWidth: 420

    readonly property int maxRows: 20

    function isKernel(name) {
        return name === "linux" || /^linux-(lts|zen|hardened|rt|firmware)/.test(name);
    }

    Repeater {
        model: Status.updateList.slice(0, root.maxRows)

        delegate: Item {
            id: row
            required property var modelData
            width: root.cardWidth
            height: 20

            Mono {
                id: name
                anchors { left: parent.left; leftMargin: Theme.inset; verticalCenter: parent.verticalCenter }
                width: 170
                elide: Text.ElideRight
                text: row.modelData.name
                color: root.isKernel(row.modelData.name) ? Theme.yellow : Theme.fg
            }
            Mono {
                anchors {
                    left: name.right
                    leftMargin: 10
                    right: parent.right
                    rightMargin: Theme.inset
                    verticalCenter: parent.verticalCenter
                }
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideMiddle
                text: row.modelData.from + " → " + row.modelData.to
                color: Theme.subtext
            }
        }
    }

    Mono {
        visible: Status.updateList.length > root.maxRows
        leftPadding: Theme.inset
        topPadding: 4
        text: "+" + (Status.updateList.length - root.maxRows) + " more"
        color: Theme.subtext
    }
}
