import QtQuick
import qs
import qs.services

// 1 2 3 4 as pills; the active one on this output is stretched and filled,
// blue when this output has keyboard focus too. Empty workspaces are dim.
Row {
    id: root

    required property string output

    spacing: 4

    Repeater {
        model: Niri.workspacesOn(root.output)

        delegate: MouseArea {
            id: ws

            required property var modelData
            readonly property bool active: modelData.is_active
            readonly property bool empty: modelData.active_window_id === null

            implicitWidth: active ? 38 : 24
            implicitHeight: 24
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Niri.focusWorkspace(modelData)

            Behavior on implicitWidth { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSmall
                color: ws.modelData.is_urgent ? Theme.red
                     : ws.active && ws.modelData.is_focused ? Theme.accent
                     : ws.active || ws.containsMouse ? Theme.bgHighlight
                     : "transparent"
                Behavior on color { ColorAnimation { duration: 160 } }
            }

            Mono {
                anchors.centerIn: parent
                text: ws.modelData.name ?? ws.modelData.idx
                font.pixelSize: 11
                font.weight: ws.active ? Font.DemiBold : Font.Normal
                color: ws.modelData.is_urgent || (ws.active && ws.modelData.is_focused) ? Theme.bgDark
                     : ws.active ? Theme.fg
                     : ws.empty ? Theme.comment
                     : Theme.fgDark
            }
        }
    }
}
