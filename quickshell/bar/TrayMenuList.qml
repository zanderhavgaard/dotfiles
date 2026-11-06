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
                color: Theme.bgHighlight
            }

            // the entry itself
            Rectangle {
                id: row
                visible: !entry.modelData.isSeparator
                x: 5
                width: parent.width - 10
                implicitWidth: rowContent.implicitWidth + 2 * Theme.inset + root.depth * Theme.inset
                implicitHeight: 28
                radius: 6
                color: area.containsMouse && entry.modelData.enabled ? Theme.bgHighlight : "transparent"

                RowLayout {
                    id: rowContent
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.inset - 5 + root.depth * Theme.inset
                        rightMargin: Theme.inset - 5
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 8

                    // check / radio state
                    Icon {
                        visible: entry.modelData.buttonType !== QsMenuButtonType.None
                        readonly property bool on: entry.modelData.checkState === Qt.Checked
                        text: entry.modelData.buttonType === QsMenuButtonType.RadioButton
                            ? (on ? Theme.glyph.radioOn : Theme.glyph.radioOff)
                            : (on ? Theme.glyph.checked : Theme.glyph.unchecked)
                        color: on ? Theme.accent : Theme.subtext
                        font.pixelSize: 14
                    }
                    IconImage {
                        visible: entry.modelData.icon !== ""
                        implicitSize: 14
                        source: entry.modelData.icon
                    }
                    Label {
                        Layout.fillWidth: true
                        text: entry.modelData.text.replace(/_(?!_)/g, "").replace(/__/g, "_")  // drop mnemonics
                        color: entry.modelData.enabled ? Theme.fg : Theme.subtext
                        elide: Text.ElideRight
                    }
                    Icon {
                        visible: entry.modelData.hasChildren
                        text: entry.expanded ? Theme.glyph.collapse : Theme.glyph.expand
                        color: Theme.subtext
                        font.pixelSize: 13
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
