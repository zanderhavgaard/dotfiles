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

    Card {
        id: card
        // below the bar, right-aligned to the icon, kept on screen
        width: Math.max(200, Math.min(360, list.implicitWidth + 2))
        height: header.height + list.implicitHeight + 12
        x: Math.max(Theme.gap, Math.min(root.width - width - Theme.gap, root.anchorX - width + 20))
        y: Theme.gap + Theme.barSize + Theme.popupOffset - 5
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
            height: 34

            Label {
                anchors { left: parent.left; leftMargin: Theme.inset; right: parent.right; rightMargin: Theme.inset; verticalCenter: parent.verticalCenter }
                text: root.trayItem ? root.trayItem.tooltipTitle || root.trayItem.title || root.trayItem.id : ""
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: Theme.inset; rightMargin: Theme.inset }
                height: 1
                color: Theme.bgHighlight
            }
        }

        TrayMenuList {
            id: list
            x: 1
            y: header.height + 6
            width: parent.width - 2
            handle: root.trayItem ? root.trayItem.menu : null
            onDone: root.dismissed()
        }
    }
}
