import QtQuick
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs
import qs.services

// One notification record (see services/Notifs.qml), used by both the
// popups and the notification center.
//   [icon]  Summary ................ age  ×
//           body
//           [action] [action]
// × dismisses it for good. Action buttons only exist while the app still
// has the notification open.
Card {
    id: card

    required property var record
    property bool inCenter: false
    readonly property bool critical: record.urgency === NotificationUrgency.Critical

    signal clicked

    width: 360
    implicitHeight: content.implicitHeight + 28
    // in the center: flat, one step up from the panel
    shadow: !inCenter
    color: inCenter ? Theme.bg : Theme.bgDark
    border.color: critical ? Theme.red : inCenter ? Theme.bgHighlight : Theme.gutter

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: card.clicked()
    }

    // app icon, or a bell in a tinted tile
    Rectangle {
        id: tile
        x: 14
        y: 14
        width: 36
        height: 36
        radius: 10
        color: icon.visible ? "transparent" : Qt.alpha(card.critical ? Theme.red : Theme.accent, 0.16)

        IconImage {
            id: icon
            anchors.fill: parent
            source: card.record.icon || ""
            visible: source != "" && status === Image.Ready
        }
        Icon {
            anchors.centerIn: parent
            visible: !icon.visible
            text: Theme.glyph.bell
            color: card.critical ? Theme.red : Theme.accent
            font.pixelSize: 18
        }
    }

    Column {
        id: content
        anchors {
            left: tile.right
            leftMargin: 12
            right: parent.right
            rightMargin: 14
        }
        y: 14
        spacing: 4

        // summary + age (or × while hovered)
        Item {
            width: parent.width
            height: summary.implicitHeight

            Label {
                id: summary
                anchors { left: parent.left; right: age.left; rightMargin: 8 }
                text: card.record.summary || card.record.appName || "Notification"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            Label {
                id: age
                anchors { right: parent.right; top: parent.top; topMargin: 1 }
                visible: !hover.containsMouse && !closeArea.containsMouse
                text: Notifs.age(card.record)
                color: Theme.subtext
                font.pixelSize: 11
            }
            MouseArea {
                id: closeArea
                anchors { right: parent.right; top: parent.top; topMargin: -4 }
                width: 22
                height: 22
                visible: hover.containsMouse || containsMouse
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Notifs.dismiss(card.record)

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: closeArea.containsMouse ? Theme.bgHighlight : "transparent"
                }
                Icon {
                    anchors.centerIn: parent
                    text: Theme.glyph.close
                    color: closeArea.containsMouse ? Theme.red : Theme.subtext
                    font.pixelSize: 13
                }
            }
        }

        Label {
            width: parent.width
            visible: card.record.summary !== "" && card.record.appName !== ""
            text: card.record.appName
            color: Theme.subtext
            font.pixelSize: 11
        }

        Label {
            visible: text !== ""
            width: parent.width
            text: card.record.body
            color: Theme.fgDark
            lineHeight: 1.25
            wrapMode: Text.Wrap
            maximumLineCount: card.inCenter ? 12 : 6
            elide: Text.ElideRight
            // sanitized in Notifs.sanitize()
            textFormat: Text.StyledText
        }

        Row {
            visible: card.record.notif !== null && card.record.notif.actions.length > 0
            topPadding: 6
            spacing: 6

            Repeater {
                model: card.record.notif ? card.record.notif.actions : []

                delegate: MouseArea {
                    id: action
                    required property NotificationAction modelData
                    required property int index
                    implicitWidth: actionText.implicitWidth + 24
                    implicitHeight: 28
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.invoke()

                    // the first action is the primary one
                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radiusSmall
                        color: action.containsMouse ? Theme.bgVisual : Theme.bgHighlight
                        border.width: 1
                        border.color: action.index === 0 ? Theme.accent : Theme.gutter
                    }
                    Label {
                        id: actionText
                        anchors.centerIn: parent
                        text: action.modelData.text
                    }
                }
            }
        }
    }
}
