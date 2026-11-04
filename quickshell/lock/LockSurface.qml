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
        source: root.lock.wallpaper !== "" ? "file://" + root.lock.wallpaper : ""
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
        color: Theme.sumiInk0
        opacity: 0.72
    }

    // ---- centre: clock, date, password -----------------------------------
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -40
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(clock.date, "hh:mm")
            color: Theme.fujiWhite
            font.family: Theme.mono
            font.pixelSize: 96
            font.weight: Font.Light
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Theme.englishDateLong(clock.date)
            color: Theme.oldWhite
            font.family: Theme.mono
            font.pixelSize: 15
            font.letterSpacing: 2
            font.capitalization: Font.AllUppercase
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 6
            text: Theme.kanjiDate(clock.date)
            color: Theme.mutedText
            font.family: Theme.serif
            font.pixelSize: 15
        }

        Item { width: 1; height: 48 }

        // password box: a hairline frame, one square per typed character
        Rectangle {
            id: box
            anchors.horizontalCenter: parent.horizontalCenter
            width: 340
            height: 46
            color: Theme.sumiInk0
            border.width: 1
            border.color: root.lock.status === "wrong" ? Theme.waveRed
                : root.lock.password !== "" ? Theme.focus
                : Theme.sumiInk6

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

            Text {
                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                visible: root.lock.password === ""
                text: root.lock.status === "checking" ? "" : "password"
                color: Theme.fujiGray
                font.family: Theme.mono
                font.pixelSize: 13
                font.letterSpacing: 1
            }

            Row {
                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                spacing: 6

                Repeater {
                    model: Math.min(root.lock.password.length, 28)
                    Rectangle {
                        width: 7
                        height: 7
                        color: Theme.fujiWhite
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
                enabled: root.lock.status !== "checking"

                Component.onCompleted: forceActiveFocus()

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
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 12
            height: 30
            text: root.lock.status === "wrong" && root.lock.failures > 1
                ? root.lock.statusText + " · " + root.lock.failures + " failed"
                : root.lock.statusText
            visible: root.lock.status !== ""
            color: root.lock.status === "wrong" || root.lock.status === "error" ? Theme.waveRed
                : root.lock.status === "ok" ? Theme.springGreen
                : Theme.oldWhite
            font.family: Theme.mono
            font.pixelSize: 12
            font.letterSpacing: 1
        }
    }

    // ---- footer ----------------------------------------------------------
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: Theme.barHeight
        color: Theme.sumiInk0

        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 1
            color: Theme.sumiInk5
        }

        Text {
            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
            text: Quickshell.env("USER") + "@" + hostnameFile.text().trim()
                + (root.preview ? "  ·  preview" : "")
            color: Theme.mutedText
            font.family: Theme.mono
            font.pixelSize: 11
            font.letterSpacing: 1
        }

        // the keyboard layout matters when typing a password
        Text {
            anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
            text: (Status.hasBattery ? "BAT " + Status.batteryPercent + (Status.charging ? "+" : "") + "  ·  " : "")
                + "KB " + Niri.layoutShort.toUpperCase()
            color: Theme.mutedText
            font.family: Theme.mono
            font.pixelSize: 11
            font.letterSpacing: 1
        }
    }
}
