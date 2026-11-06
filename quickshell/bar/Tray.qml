import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

// StatusNotifierItem tray. Left click activates (or opens the menu for
// menu-only items), right click opens the menu (TrayMenu.qml, drawn in the
// shell's style), middle click is the secondary action, scroll is passed
// through.
Row {
    id: root

    readonly property int count: SystemTray.items.values.length

    // the item whose menu is open, and the centre of its icon on screen
    property var menuItem: null
    property real menuX: 0

    spacing: 10

    LazyLoader {
        active: root.menuItem !== null

        TrayMenu {
            screen: root.QsWindow.window ? root.QsWindow.window.screen : null
            trayItem: root.menuItem
            anchorX: root.menuX
            onDismissed: root.menuItem = null
        }
    }

    Repeater {
        model: SystemTray.items

        delegate: WheelArea {
            id: item

            required property SystemTrayItem modelData

            implicitWidth: 16
            implicitHeight: 16
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor

            function openMenu() {
                // the bar spans the screen, so window x is screen x
                root.menuX = QsWindow.itemPosition(item).x + width / 2;
                root.menuItem = modelData;
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
            onScrolled: steps => modelData.scroll(steps, false)

            IconImage {
                anchors.fill: parent
                source: item.modelData.icon
                // NeedsAttention items stay at full strength, passive ones dim
                // (Status here is the SystemTray enum, not qs.services.Status)
                opacity: item.modelData.status === Status.Passive ? 0.6 : 1
            }
        }
    }
}
