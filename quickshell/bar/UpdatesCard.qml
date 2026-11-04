import QtQuick
import qs
import qs.services

// Hover card above the ↑N update count: package, old → new version.
// Kernel packages are yellow, since they mean a reboot afterwards.
HoverCard {
    id: root

    title: "updates"
    aside: Status.updates + " pending"
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

            Text {
                id: name
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                width: 170
                elide: Text.ElideRight
                text: row.modelData.name
                color: root.isKernel(row.modelData.name) ? Theme.carpYellow : Theme.fujiWhite
                font.family: Theme.mono
                font.pixelSize: 11
            }
            Text {
                anchors {
                    left: name.right
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideMiddle
                text: row.modelData.from + " → " + row.modelData.to
                color: Theme.mutedText
                font.family: Theme.mono
                font.pixelSize: 11
            }
        }
    }

    Text {
        visible: Status.updateList.length > root.maxRows
        leftPadding: 14
        topPadding: 4
        text: "+" + (Status.updateList.length - root.maxRows) + " more"
        color: Theme.mutedText
        font.family: Theme.mono
        font.pixelSize: 11
    }

    Text {
        leftPadding: 14
        topPadding: 8
        text: "click to update with paru"
        color: Theme.mutedText
        font.family: Theme.mono
        font.pixelSize: 10
        font.letterSpacing: 1
        font.capitalization: Font.AllUppercase
    }
}
