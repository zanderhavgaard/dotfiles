import QtQuick
import Quickshell.Services.Notifications
import qs
import qs.services

// One notification record (see services/Notifs.qml), used by both the
// popups and the notification center.
// Header: APPNAME · age ........ ×   (× dismisses it for good)
// Action buttons only exist while the app still has the notification open.
Rectangle {
    id: card

    required property var record
    property bool inCenter: false
    readonly property bool critical: record.urgency === NotificationUrgency.Critical

    signal clicked

    width: 360
    implicitHeight: body.implicitHeight
    color: Theme.sumiInk0
    border.width: 1
    border.color: critical ? Theme.waveRed : Theme.sumiInk6

    MouseArea {
        anchors.fill: parent
        onClicked: card.clicked()
    }

    Column {
        id: body
        width: parent.width

        Item {
            width: parent.width
            height: 30

            Caps {
                anchors { left: parent.left; leftMargin: Theme.inset; verticalCenter: parent.verticalCenter }
                text: (card.record.appName || "notification") + "  ·  " + Notifs.age(card.record)
            }

            // dismiss
            MouseArea {
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                width: 34
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: Notifs.dismiss(card.record)

                Mono {
                    anchors.centerIn: parent
                    text: "×"
                    color: parent.containsMouse ? Theme.waveRed : Theme.mutedText
                    font.pixelSize: 14
                }
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 1 }
                height: 1
                color: Theme.sumiInk4
            }
        }

        Column {
            x: Theme.inset
            width: parent.width - 2 * Theme.inset
            topPadding: 12
            bottomPadding: 14
            spacing: 6

            Mono {
                width: parent.width
                text: card.record.summary
                font.pixelSize: 13
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
            }
            Mono {
                visible: text !== ""
                width: parent.width
                text: card.record.body
                color: Theme.oldWhite
                font.pixelSize: 12
                lineHeight: 1.3
                wrapMode: Text.Wrap
                maximumLineCount: card.inCenter ? 12 : 6
                elide: Text.ElideRight
                // sanitized in Notifs.sanitize()
                textFormat: Text.StyledText
            }
            Row {
                visible: card.record.notif !== null && card.record.notif.actions.length > 0
                topPadding: 6
                spacing: 16

                Repeater {
                    model: card.record.notif ? card.record.notif.actions : []

                    delegate: Mono {
                        id: action
                        required property NotificationAction modelData
                        text: modelData.text
                        font.pixelSize: 12
                        font.underline: true

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: action.modelData.invoke()
                        }
                    }
                }
            }
        }
    }
}
