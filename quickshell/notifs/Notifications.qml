import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// Popups and the notification center, both top right (below the top bar).
// The server and history live in services/Notifs.qml.
// Their windows are Theme.gap from the screen edges, with room on the
// inner sides for the shadow.
Scope {
    id: root

    // small pill button in the center's header
    component HeaderButton: MouseArea {
        id: hb
        property string text
        property bool highlight: false
        implicitWidth: hbText.implicitWidth + 20
        implicitHeight: 24
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: hb.highlight ? Qt.alpha(Theme.yellow, 0.16) : hb.containsMouse ? Theme.bgHighlight : "transparent"
            border.width: 1
            border.color: hb.highlight ? Theme.yellow : Theme.gutter
        }
        Label {
            id: hbText
            anchors.centerIn: parent
            text: hb.text
            color: hb.highlight ? Theme.yellow : hb.containsMouse ? Theme.fg : Theme.fgDark
            font.pixelSize: 11
        }
    }

    // ---- popups ------------------------------------------------------------
    PanelWindow {
        visible: Notifs.popups.length > 0 && !Notifs.centerOpen
        anchors {
            top: true
            right: true
        }
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: 0
        implicitWidth: 360 + Theme.shadowPad + Theme.gap
        implicitHeight: Math.max(1, popupColumn.implicitHeight + Theme.gap + Theme.shadowPad)
        color: "transparent"
        mask: Region { item: popupColumn }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-notifications"

        Column {
            id: popupColumn
            x: Theme.shadowPad
            y: Theme.gap
            width: 360
            spacing: Theme.gap

            Repeater {
                // ScriptModel keeps the other popups (and their timers) when one goes
                model: ScriptModel { values: Notifs.popups }

                delegate: NotifCard {
                    id: popup
                    required property var modelData
                    record: modelData
                    // clicking a popup just tucks it away into the center
                    onClicked: Notifs.hidePopup(modelData)

                    // expireTimeout is in seconds; <= 0 means "server decides"
                    Timer {
                        running: !popup.critical
                        interval: popup.modelData.notif && popup.modelData.notif.expireTimeout > 0
                            ? popup.modelData.notif.expireTimeout * 1000 : 6000
                        onTriggered: Notifs.hidePopup(popup.modelData)
                    }
                }
            }
        }
    }

    // ---- center ------------------------------------------------------------
    LazyLoader {
        active: Notifs.centerOpen

        PanelWindow {
            id: centerWindow
            anchors {
                top: true
                right: true
            }
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: 0
            implicitWidth: 400 + Theme.shadowPad + Theme.gap
            implicitHeight: panel.height + Theme.gap + Theme.shadowPad
            color: "transparent"
            mask: Region { item: panel }
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            WlrLayershell.namespace: "qs-notification-center"

            Card {
                id: panel
                x: Theme.shadowPad
                y: Theme.gap
                width: 400
                // header + list (at least room for the empty state) + list margins
                height: Math.min(header.height + Math.max(list.contentHeight, 80) + 20,
                                 Math.round((centerWindow.screen ? centerWindow.screen.height : 900) * 0.75))
                focus: true
                Keys.onEscapePressed: Notifs.centerOpen = false

                // header: Notifications 3 ....... (dnd) (clear)
                Item {
                    id: header
                    width: parent.width
                    height: 48

                    Row {
                        anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                        spacing: 8

                        Label {
                            text: "Notifications"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                        }
                        Mono {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: Notifs.count > 0
                            text: Notifs.count
                            color: Theme.subtext
                        }
                    }

                    Row {
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        spacing: 6

                        HeaderButton {
                            text: Notifs.dnd ? "Do not disturb" : "DND off"
                            highlight: Notifs.dnd
                            onClicked: Notifs.dnd = !Notifs.dnd
                        }
                        HeaderButton {
                            visible: Notifs.count > 0
                            text: "Clear all"
                            onClicked: Notifs.clearAll()
                        }
                    }

                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 12; rightMargin: 12 }
                        height: 1
                        color: Theme.bgHighlight
                    }
                }

                ListView {
                    id: list
                    anchors {
                        top: header.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        margins: 10
                    }
                    clip: true
                    spacing: 8
                    // ScriptModel: a new notification doesn't rebuild the list or
                    // scroll it back to the top
                    model: ScriptModel { values: Notifs.history }
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: NotifCard {
                        required property var modelData
                        width: list.width
                        record: modelData
                        inCenter: true
                    }

                    Label {
                        visible: Notifs.count === 0
                        anchors.centerIn: parent
                        text: "All caught up"
                        color: Theme.subtext
                        font.pixelSize: 13
                    }
                }
            }
        }
    }
}
