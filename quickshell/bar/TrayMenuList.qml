import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs

// The entries of one tray menu (or submenu). Submenus open inline, indented,
// by loading this same file again.
ColumnLayout {
    id: root

    required property var handle    // QsMenuHandle: the tray item's menu, or an entry with children
    property int depth: 0

    signal done    // an entry was triggered: close the whole menu

    spacing: 0

    QsMenuOpener {
        id: opener
        menu: root.handle
    }

    Repeater {
        model: opener.children

        delegate: Item {
            id: entry

            required property QsMenuEntry modelData
            property bool expanded: false

            Layout.fillWidth: true
            implicitWidth: modelData.isSeparator ? 0 : row.implicitWidth
            implicitHeight: modelData.isSeparator ? 9 : row.implicitHeight + (sub.item ? sub.item.implicitHeight : 0)

            // separator
            Rectangle {
                visible: entry.modelData.isSeparator
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                anchors.leftMargin: Theme.inset
                anchors.rightMargin: Theme.inset
                height: 1
                color: Theme.sumiInk4
            }

            // the entry itself
            Rectangle {
                id: row
                visible: !entry.modelData.isSeparator
                width: parent.width
                implicitWidth: rowContent.implicitWidth + 2 * Theme.inset + root.depth * Theme.inset
                implicitHeight: 26
                color: area.containsMouse && entry.modelData.enabled ? Theme.waveBlue1 : "transparent"

                RowLayout {
                    id: rowContent
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.inset + root.depth * Theme.inset
                        rightMargin: Theme.inset
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 8

                    // check / radio state: square boxes, round dots
                    Mono {
                        visible: entry.modelData.buttonType !== QsMenuButtonType.None
                        text: entry.modelData.buttonType === QsMenuButtonType.RadioButton
                            ? (entry.modelData.checkState === Qt.Checked ? "●" : "○")
                            : (entry.modelData.checkState === Qt.Checked ? "■" : "□")
                        color: entry.modelData.checkState === Qt.Checked ? Theme.focus : Theme.fujiGray
                    }
                    IconImage {
                        visible: entry.modelData.icon !== ""
                        implicitSize: 14
                        source: entry.modelData.icon
                    }
                    Mono {
                        Layout.fillWidth: true
                        text: entry.modelData.text.replace(/_(?!_)/g, "").replace(/__/g, "_")  // drop mnemonics
                        color: entry.modelData.enabled ? Theme.fujiWhite : Theme.fujiGray
                        elide: Text.ElideRight
                    }
                    Mono {
                        visible: entry.modelData.hasChildren
                        text: entry.expanded ? "−" : "+"
                        color: Theme.mutedText
                    }
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: entry.modelData.enabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (entry.modelData.hasChildren) {
                            entry.expanded = !entry.expanded;
                        } else {
                            entry.modelData.triggered();
                            root.done();
                        }
                    }
                }
            }

            // submenu, below its entry (by URL: a file can't name itself as a type)
            Loader {
                id: sub
                active: entry.expanded
                y: row.implicitHeight
                width: parent.width
                Component.onCompleted: setSource("TrayMenuList.qml", { handle: entry.modelData, depth: root.depth + 1 })
            }
            Connections {
                target: sub.item
                function onDone() { root.done(); }
            }
        }
    }
}
