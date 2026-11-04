import QtQuick
import qs
import qs.services

// 一 二 三 四 — the active workspace on this output gets an underline,
// green when this output also has keyboard focus.
Row {
    id: root

    required property string output

    spacing: 14

    Repeater {
        model: Niri.workspacesOn(root.output)

        delegate: MouseArea {
            id: ws

            required property var modelData
            readonly property bool empty: modelData.active_window_id === null

            implicitWidth: glyph.implicitWidth + 4
            implicitHeight: Theme.barHeight
            cursorShape: Qt.PointingHandCursor
            onClicked: Niri.focusWorkspace(modelData)

            Text {
                id: glyph
                anchors.centerIn: parent
                text: ws.modelData.name ?? Theme.kanji(ws.modelData.idx)
                font.family: Theme.serif
                font.pixelSize: 15
                font.bold: ws.modelData.is_active
                color: ws.modelData.is_urgent ? Theme.waveRed
                     : ws.modelData.is_active ? Theme.fujiWhite
                     : ws.empty ? Theme.fujiGray
                     : Theme.oldWhite
            }

            Rectangle {
                visible: ws.modelData.is_active
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: glyph.bottom
                anchors.topMargin: 1
                width: glyph.implicitWidth + 4
                height: 2
                color: ws.modelData.is_focused ? Theme.focus : Theme.sumiInk6
            }
        }
    }
}
