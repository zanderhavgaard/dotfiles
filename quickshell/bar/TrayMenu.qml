import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

// A tray item's menu, drawn in the shell's style instead of as a native Qt
// menu. A transparent full-screen overlay catches the click that closes it
// (anywhere outside the card), and Esc.
PanelWindow {
    id: root

    required property var trayItem   // SystemTrayItem
    required property real anchorX   // tray icon centre, in screen coordinates

    signal dismissed

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "qs-tray-menu"

    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
    }

    Rectangle {
        id: card
        // above the bar, right-aligned to the icon, kept on screen
        width: Math.max(200, Math.min(360, list.implicitWidth + 2))
        height: header.height + list.implicitHeight + 10
        x: Math.max(Theme.gap, Math.min(root.width - width - Theme.gap, root.anchorX - width + 20))
        y: root.height - Theme.barHeight - 8 - height
        color: Theme.sumiInk0
        border.width: 1
        border.color: Theme.sumiInk6
        focus: true
        Keys.onEscapePressed: root.dismissed()

        // swallow clicks so they don't close the menu
        MouseArea {
            anchors.fill: parent
        }

        Item {
            id: header
            x: 1
            width: parent.width - 2
            height: 28

            Caps {
                anchors { left: parent.left; leftMargin: Theme.inset; right: parent.right; rightMargin: Theme.inset; verticalCenter: parent.verticalCenter }
                text: root.trayItem ? root.trayItem.tooltipTitle || root.trayItem.title || root.trayItem.id : ""
                elide: Text.ElideRight
            }
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1
                color: Theme.sumiInk4
            }
        }

        TrayMenuList {
            id: list
            x: 1
            y: header.height + 5
            width: parent.width - 2
            handle: root.trayItem ? root.trayItem.menu : null
            onDone: root.dismissed()
        }
    }
}
