import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs
import qs.services

// Popups (top right) and the notification center (bottom right, above the
// bell in the bar). The server and history live in services/Notifs.qml.
Scope {
    id: root

    // ---- popups ------------------------------------------------------------
    PanelWindow {
        visible: Notifs.popups.length > 0 && !Notifs.centerOpen
        anchors {
            top: true
            right: true
        }
        margins {
            top: Theme.gap
            right: Theme.gap
        }
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: 0
        implicitWidth: 360
        implicitHeight: Math.max(1, popupColumn.implicitHeight)
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-notifications"

        Column {
            id: popupColumn
            width: parent.width
            spacing: Theme.gap

            Repeater {
                model: Notifs.popups

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
            anchors {
                bottom: true
                right: true
            }
            margins {
                bottom: Theme.gap
                right: Theme.gap
            }
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: 0
            implicitWidth: 380
            implicitHeight: Math.min(panel.implicitHeight, Math.round((screen ? screen.height : 900) * 0.75))
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            WlrLayershell.namespace: "qs-notification-center"

            Rectangle {
                id: panel
                anchors.fill: parent
                // header + list (at least room for the empty state) + list margins
                implicitHeight: header.height + Math.max(list.contentHeight, 60) + 22
                color: Theme.sumiInk1
                border.width: 1
                border.color: Theme.sumiInk5
                focus: true
                Keys.onEscapePressed: Notifs.centerOpen = false

                // header: NOTIFICATIONS 3 ....... DND · CLEAR
                Item {
                    id: header
                    x: 1
                    y: 1
                    width: parent.width - 2
                    height: 36

                    Text {
                        anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                        text: "notifications" + (Notifs.count > 0 ? "  " + Notifs.count : "")
                        color: Theme.oldWhite
                        font.family: Theme.mono
                        font.pixelSize: 11
                        font.letterSpacing: 1
                        font.capitalization: Font.AllUppercase
                    }

                    Row {
                        anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                        spacing: 16

                        HeaderButton {
                            text: Notifs.dnd ? "dnd on" : "dnd off"
                            highlight: Notifs.dnd
                            onActivated: Notifs.dnd = !Notifs.dnd
                        }
                        HeaderButton {
                            visible: Notifs.count > 0
                            text: "clear"
                            onActivated: Notifs.clearAll()
                        }
                    }

                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                        height: 1
                        color: Theme.sumiInk4
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
                    model: Notifs.history
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: NotifCard {
                        required property var modelData
                        width: list.width
                        record: modelData
                        inCenter: true
                    }

                    Text {
                        visible: Notifs.count === 0
                        anchors.centerIn: parent
                        text: "nothing here"
                        color: Theme.fujiGray
                        font.family: Theme.mono
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}
