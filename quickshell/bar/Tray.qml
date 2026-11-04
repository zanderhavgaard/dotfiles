import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs

// StatusNotifierItem tray. Left click activates (or opens the menu for
// menu-only items), right click opens the menu, middle click is the
// secondary action, scroll is passed through.
Row {
    id: root

    required property var barWindow
    readonly property int count: SystemTray.items.values.length

    spacing: 10

    Repeater {
        model: SystemTray.items

        delegate: MouseArea {
            id: item

            required property SystemTrayItem modelData

            implicitWidth: 16
            implicitHeight: 16
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor

            function openMenu() {
                const p = item.mapToItem(root.barWindow.contentItem, 0, 0);
                modelData.display(root.barWindow, p.x, p.y);
            }

            onClicked: mouse => {
                if (mouse.button === Qt.MiddleButton) {
                    modelData.secondaryActivate();
                } else if (mouse.button === Qt.RightButton || modelData.onlyMenu) {
                    if (modelData.hasMenu) openMenu();
                } else {
                    modelData.activate();
                }
            }
            // scroll() takes whole notches; add up touchpad deltas until one is reached
            property real wheelAccum: 0
            onWheel: wheel => {
                wheelAccum += wheel.angleDelta.y;
                const steps = wheelAccum > 0 ? Math.floor(wheelAccum / 120) : Math.ceil(wheelAccum / 120);
                if (steps === 0) return;
                wheelAccum -= steps * 120;
                modelData.scroll(steps, false);
            }

            IconImage {
                anchors.fill: parent
                source: item.modelData.icon
                // NeedsAttention items stay at full strength, passive ones dim
                opacity: item.modelData.status === Status.Passive ? 0.6 : 1
            }
        }
    }
}
