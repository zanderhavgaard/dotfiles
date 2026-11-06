import QtQuick
import QtQuick.Effects

// A floating surface: rounded, 1px border, soft shadow. Its window needs
// Theme.shadowPad of transparent room around it for the shadow.
Rectangle {
    property bool shadow: true

    color: Theme.bgDark
    radius: Theme.radius
    border.width: 1
    border.color: Theme.gutter

    RectangularShadow {
        z: -1
        visible: parent.shadow
        anchors.fill: parent
        radius: parent.radius
        offset.y: 6
        blur: 22
        color: Qt.rgba(0, 0, 0, 0.5)
    }
}
