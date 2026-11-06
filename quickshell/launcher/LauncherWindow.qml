import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs

// The launcher's window: dimmed backdrop, card with a search field,
// results, key hints. Matching and history live in Launcher.qml.
PanelWindow {
    id: win

    required property var launcher

    property string query: ""
    property int selected: 0

    readonly property var results: launcher.appResults(query)

    onQueryChanged: selected = 0

    // move the selection by n, wrapping around both ends
    function step(n) {
        const len = results.length;
        if (len > 0) selected = ((selected + n) % len + len) % len;
    }

    function activate(r) {
        if (r) launcher.launch(r.entry);
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: Qt.alpha(Theme.bgDark, 0.35)   // dims the desktop
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "qs-launcher"

    // click outside the card closes
    MouseArea {
        anchors.fill: parent
        onClicked: win.launcher.open = false
    }

    // ---- card ----------------------------------------------------
    Card {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(parent.height * 0.18)
        width: 580
        height: content.implicitHeight + 2
        radius: 16

        // swallow clicks so they don't reach the close-on-click area
        MouseArea {
            anchors.fill: parent
        }

        Column {
            id: content
            x: 1
            y: 1
            width: parent.width - 2

            // search field
            Item {
                width: parent.width
                height: 56

                Icon {
                    id: prompt
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                    text: Theme.glyph.search
                    color: Theme.accent
                    font.pixelSize: 18
                }

                Label {
                    anchors { left: input.left; verticalCenter: parent.verticalCenter }
                    visible: input.text === ""
                    text: "Search apps"
                    color: Theme.subtext
                    font.pixelSize: 15
                }

                TextInput {
                    id: input
                    anchors {
                        left: prompt.right
                        leftMargin: 12
                        right: parent.right
                        rightMargin: 20
                        verticalCenter: parent.verticalCenter
                    }
                    focus: true
                    color: Theme.fg
                    selectionColor: Theme.bgVisual
                    font.family: Theme.sans
                    font.pixelSize: 15
                    onTextChanged: win.query = text

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            win.launcher.open = false;
                        } else if (event.key === Qt.Key_Backtab || event.key === Qt.Key_Up
                                   || (event.key === Qt.Key_P && event.modifiers & Qt.ControlModifier)) {
                            win.step(-1);
                        } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Down
                                   || (event.key === Qt.Key_N && event.modifiers & Qt.ControlModifier)) {
                            win.step(1);
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            win.activate(win.results[win.selected]);
                        } else {
                            return;
                        }
                        event.accepted = true;
                    }
                }

                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 12; rightMargin: 12 }
                    height: 1
                    color: Theme.bgHighlight
                }
            }

            // results
            Column {
                width: parent.width
                topPadding: 8
                bottomPadding: 8
                leftPadding: 8
                rightPadding: 8
                spacing: 2

                Repeater {
                    model: win.results

                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property bool isSelected: index === win.selected

                        width: parent.width - 16
                        height: 48
                        radius: 10
                        color: isSelected ? Theme.bgVisual : "transparent"

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: win.selected = row.index
                            onClicked: win.activate(row.modelData)
                        }

                        // icon, or a letter tile when there isn't one
                        Rectangle {
                            id: tile
                            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                            width: 32
                            height: 32
                            radius: 8
                            color: icon.visible ? "transparent" : Theme.bgHighlight

                            IconImage {
                                id: icon
                                anchors.centerIn: parent
                                implicitSize: 28
                                source: Quickshell.iconPath(row.modelData.icon, true)
                                visible: source != ""
                            }
                            Label {
                                anchors.centerIn: parent
                                visible: !icon.visible
                                text: row.modelData.letter
                                color: Theme.accent
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                            }
                        }

                        Column {
                            anchors {
                                left: tile.right
                                leftMargin: 12
                                right: enter.left
                                rightMargin: 12
                                verticalCenter: parent.verticalCenter
                            }

                            Label {
                                width: parent.width
                                text: row.modelData.title
                                // match highlighting; the name itself is escaped
                                textFormat: Text.StyledText
                                elide: Text.ElideRight
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                            Label {
                                width: parent.width
                                visible: text !== ""
                                text: row.modelData.subtitle
                                elide: Text.ElideRight
                                color: row.isSelected ? Theme.fgDark : Theme.subtext
                                font.pixelSize: 11
                            }
                        }

                        Mono {
                            id: enter
                            anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                            visible: row.isSelected
                            text: "↵"
                            color: Theme.fgDark
                        }
                    }
                }

                Label {
                    visible: win.results.length === 0
                    leftPadding: 12
                    topPadding: 8
                    bottomPadding: 8
                    text: "no matches"
                    color: Theme.subtext
                    font.pixelSize: 12
                }
            }

            // footer
            Rectangle {
                x: 12
                width: parent.width - 24
                height: 1
                color: Theme.bgHighlight
            }
            Item {
                width: parent.width
                height: 34

                Row {
                    anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
                    spacing: 16

                    Repeater {
                        model: [["↵", "open"], ["⇥", "next"], ["esc", "close"]]
                        delegate: Label {
                            required property var modelData
                            text: "<font color=\"" + Theme.fg + "\">" + modelData[0] + "</font> " + modelData[1]
                            textFormat: Text.StyledText
                            color: Theme.subtext
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
}
