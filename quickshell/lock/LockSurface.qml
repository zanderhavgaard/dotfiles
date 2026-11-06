import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs
import qs.services

// What each screen shows while locked: blurred wallpaper, clock, password box.
// All state lives on the Lock scope, so every screen shows the same input.
Item {
    id: root

    required property var lock
    property bool preview: false

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    FileView {
        id: hostnameFile
        path: "/etc/hostname"
    }

    // ---- background ------------------------------------------------------
    Image {
        id: wallpaper
        anchors.fill: parent
        source: root.lock.wallpaper !== "" ? "file://" + encodeURI(root.lock.wallpaper) : ""
        // it's blurred anyway: no need to decode a 6K wallpaper per screen
        sourceSize: Qt.size(Math.max(1, Math.round(width / 2)), Math.max(1, Math.round(height / 2)))
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: wallpaper
        visible: wallpaper.status === Image.Ready
        autoPaddingEnabled: false
        blurEnabled: true
        blurMax: 48
        blur: 1.0
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bgDark
        opacity: 0.6
    }

    // ---- centre: clock, date, password -----------------------------------
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -40
        spacing: 0

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(clock.date, "hh:mm")
            font.pixelSize: 112
            font.weight: Font.Light
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Theme.englishDateLong(clock.date)
            color: Theme.fgDark
            font.pixelSize: 18
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 4
            text: Theme.kanjiDate(clock.date)
            color: Theme.subtext
            font.family: Theme.japanese
            font.pixelSize: 14
        }

        Item { width: 1; height: 44 }

        // password pill: one dot per typed character
        Rectangle {
            id: box
            anchors.horizontalCenter: parent.horizontalCenter
            width: 340
            height: 48
            radius: height / 2
            color: Qt.alpha(Theme.bgDark, 0.85)
            border.width: 1
            border.color: root.lock.status === "wrong" ? Theme.red
                : root.lock.password !== "" ? Theme.accent
                : Theme.gutter

            Icon {
                id: lockIcon
                anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
                text: Theme.glyph.lock
                color: root.lock.status === "wrong" ? Theme.red
                    : root.lock.password !== "" ? Theme.accent : Theme.subtext
                font.pixelSize: 16
            }

            // horizontal shake on a wrong password
            transform: Translate { id: shakeOffset }
            SequentialAnimation {
                id: shake
                NumberAnimation { target: shakeOffset; property: "x"; to: -10; duration: 50 }
                NumberAnimation { target: shakeOffset; property: "x"; to: 10; duration: 80 }
                NumberAnimation { target: shakeOffset; property: "x"; to: -6; duration: 70 }
                NumberAnimation { target: shakeOffset; property: "x"; to: 0; duration: 60 }
            }
            Connections {
                target: root.lock
                function onFailuresChanged() {
                    if (root.lock.failures > 0) shake.restart();
                }
            }

            Label {
                anchors { left: lockIcon.right; leftMargin: 12; verticalCenter: parent.verticalCenter }
                visible: root.lock.password === ""
                text: root.lock.status === "checking" ? "" : "Password"
                color: Theme.subtext
                font.pixelSize: 14
            }

            Row {
                id: dots
                anchors { left: lockIcon.right; leftMargin: 12; verticalCenter: parent.verticalCenter }
                spacing: 6

                Repeater {
                    // as many dots (8px + 6px gap) as fit before the right edge
                    model: Math.min(root.lock.password.length, Math.floor((box.width - dots.x - 24 + 6) / 14))
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: Theme.fg
                    }
                }
            }

            // the real input: invisible, it only collects keystrokes
            TextInput {
                id: input
                anchors.fill: parent
                opacity: 0
                focus: true
                echoMode: TextInput.Password
                // read-only (not disabled) while checking, so Esc still works
                readOnly: root.lock.status === "checking"

                Component.onCompleted: {
                    // a screen plugged in mid-typing starts with what's typed so far
                    text = root.lock.password;
                    forceActiveFocus();
                }

                onTextChanged: {
                    if (text !== root.lock.password) root.lock.password = text;
                    if (text !== "" && root.lock.status !== "checking") root.lock.status = "";
                }

                Connections {
                    target: root.lock
                    // keep every screen's input in sync (and cleared after a failure)
                    function onPasswordChanged() {
                        if (input.text !== root.lock.password) input.text = root.lock.password;
                    }
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.lock.submit();
                    } else if (event.key === Qt.Key_Escape) {
                        root.lock.cancelCheck();
                        if (root.preview) root.lock.previewing = false;
                        else root.lock.password = "";
                    } else {
                        return;
                    }
                    event.accepted = true;
                }
            }
        }

        // status line under the box
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 12
            height: 30
            text: root.lock.status === "wrong" && root.lock.failures > 1
                ? root.lock.statusText + " · " + root.lock.failures + " failed"
                : root.lock.statusText
            visible: root.lock.status !== ""
            color: root.lock.status === "wrong" || root.lock.status === "error" ? Theme.red
                : root.lock.status === "ok" ? Theme.green
                : Theme.fgDark
            font.pixelSize: 13
        }
    }

    // ---- footer ----------------------------------------------------------
    Label {
        anchors { left: parent.left; bottom: parent.bottom; margins: 20 }
        text: Quickshell.env("USER") + "@" + hostnameFile.text().trim()
            + (root.preview ? "  ·  preview" : "")
        color: Theme.subtext
    }

    // the keyboard layout matters when typing a password
    Label {
        anchors { right: parent.right; bottom: parent.bottom; margins: 20 }
        text: (Status.hasBattery ? "battery " + Status.batteryPercent + "%" + (Status.charging ? " charging" : "") + "  ·  " : "")
            + "keyboard " + Niri.layoutShort
        color: Theme.subtext
    }
}
