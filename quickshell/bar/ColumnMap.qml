import QtQuick
import qs
import qs.services

// A to-scale sketch of the columns on this output's active workspace:
// one bar per column (width ∝ column width), split per stacked window.
// Blue: the focused window; bright: on screen; dim: scrolled out of view.
// Click: overview.
MouseArea {
    id: root

    required property string output
    required property real outputWidth   // logical px
    property real maxWidth: 160          // the map shrinks to fit

    readonly property var workspace: Niri.workspacesOn(output).find(w => w.is_active) ?? null
    readonly property var columns: workspace ? Niri.columnsOf(workspace.id) : []

    // a full-width column is 22px, then everything shrinks to fit maxWidth
    readonly property real full: {
        const units = columns.reduce((sum, c) => sum + c.width / outputWidth, 0);
        const room = maxWidth - 2 * Math.max(0, columns.length - 1);
        return Math.min(22, units > 0 ? room / units : 22);
    }

    visible: columns.length > 0
    implicitWidth: row.width
    implicitHeight: 18
    cursorShape: Qt.PointingHandCursor
    onClicked: Niri.action(["toggle-overview"])

    Row {
        id: row
        spacing: 2

        Repeater {
            model: root.columns

            delegate: Column {
                id: col
                required property var modelData
                readonly property real total: modelData.windows.reduce((s, w) => s + w.height, 0)
                spacing: 2

                Repeater {
                    model: col.modelData.windows

                    delegate: Rectangle {
                        required property var modelData
                        width: Math.max(3, Math.round(col.modelData.width / root.outputWidth * root.full))
                        height: Math.max(3, Math.round(modelData.height / col.total
                            * (root.implicitHeight - 2 * (col.modelData.windows.length - 1))))
                        radius: 2
                        color: modelData.focused ? Theme.accent
                             : modelData.shown ? Theme.fgDark
                             : Theme.gutter
                    }
                }
            }
        }
    }
}
