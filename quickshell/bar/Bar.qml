import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// Docked to the bottom edge, full width, one hairline on top.
// workspaces | kernel · updates  ...  date + time | MIC · VOL · LUM · BAT · NET · VPN · KB · bell · idle | tray
PanelWindow {
    id: bar

    required property ShellScreen modelData
    readonly property string output: modelData.name
    // window-bound things (the idle inhibitor) live on one bar only
    readonly property bool primary: Quickshell.screens.length > 0 && modelData === Quickshell.screens[0]

    screen: modelData
    anchors {
        left: true
        right: true
        bottom: true
    }
    implicitHeight: Theme.barHeight
    color: Theme.sumiInk0

    component Dot: Text {
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        text: "·"
        color: Theme.fujiGray
        font.family: Theme.mono
        font.pixelSize: 11
    }

    component Rule: Rectangle {
        width: 1
        height: 16
        color: Theme.sumiInk5
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // compositor only honours this while the bar is visible, which it always is
    IdleInhibitor {
        window: bar
        enabled: bar.primary && Status.idleInhibited
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 1
        color: Theme.sumiInk5
    }

    // ---- left: workspaces, kernel, updates ---------------------------------
    Row {
        id: left
        anchors {
            left: parent.left
            leftMargin: 12
            verticalCenter: parent.verticalCenter
        }
        spacing: 14

        Workspaces {
            output: bar.output
        }

        Rule {
            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            // yellow + "reboot" once linux was upgraded under the running kernel
            Stat {
                label: "krn"
                value: Status.kernel + (Status.kernelStale ? " reboot" : "")
                valueColor: Status.kernelStale ? Theme.carpYellow : Theme.oldWhite
                cursorShape: Qt.ArrowCursor
            }

            Dot { visible: Status.updates > 0 }
            // hover: the package list; click: paru
            Stat {
                id: updatesStat
                visible: Status.updates > 0
                label: ""
                value: "↑" + Status.updates
                valueColor: Theme.surimiOrange
                hoverEnabled: true
                onLeftClicked: Status.runUpdates()

                UpdatesCard {
                    anchorItem: updatesStat
                    hovered: updatesStat.containsMouse
                }
            }
        }
    }

    // ---- right: date + time, status, tray ----------------------------------
    Row {
        id: right
        anchors {
            right: parent.right
            rightMargin: 12
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        // date + time; click switches the date between Tue 3 Nov and 十一月三日 火曜日,
        // hover shows the world clock (UTC / Tokyo / Auckland)
        MouseArea {
            id: clockArea
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: dateTime.implicitWidth
            implicitHeight: dateTime.implicitHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Status.japaneseDate = !Status.japaneseDate

            WorldClock {
                anchorItem: clockArea
                hovered: clockArea.containsMouse
            }

            Row {
                id: dateTime
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                    anchors.baseline: time.baseline
                    text: Status.japaneseDate ? Theme.kanjiDate(clock.date) : Theme.englishDate(clock.date)
                    color: Theme.oldWhite
                    font.family: Status.japaneseDate ? Theme.serif : Theme.mono
                    font.pixelSize: 13
                }
                Text {
                    id: time
                    text: Qt.formatTime(clock.date, "hh:mm")
                    color: Theme.fujiWhite
                    font.family: Theme.mono
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }
        }

        Rule {
            anchors.verticalCenter: parent.verticalCenter
        }

        // click: mute toggle, scroll: level. Live mic is yellow so it's noticed.
        Stat {
            id: micStat
            label: "mic"
            value: Status.micMuted ? "off" : Math.round(Status.micVolume * 100)
            valueColor: Status.micMuted ? Theme.fujiGray : Theme.carpYellow
            onLeftClicked: Status.toggleMicMute()
            onRightClicked: Quickshell.execDetached(["pwvucontrol"])
            onScrolled: steps => Status.setMicVolume(Status.micVolume + steps * 0.05)
            hoverEnabled: true

            AudioCard {
                anchorItem: micStat
                hovered: micStat.containsMouse
                node: Status.source
                input: true
            }
        }

        Dot {}
        Stat {
            id: volStat
            label: "vol"
            value: Status.muted ? "mute" : Math.round(Status.volume * 100)
            valueColor: Status.muted ? Theme.fujiGray : Theme.fujiWhite
            onLeftClicked: Quickshell.execDetached(["pwvucontrol"])
            onRightClicked: Status.toggleMute()
            onScrolled: steps => Status.setVolume(Status.volume + steps * 0.05)
            hoverEnabled: true

            AudioCard {
                anchorItem: volStat
                hovered: volStat.containsMouse
                node: Status.sink
            }
        }

        Dot { visible: Status.brightness >= 0 }
        Stat {
            visible: Status.brightness >= 0
            label: "lum"
            value: Status.brightness
            onScrolled: steps => Status.stepBrightness(steps)
        }

        Dot { visible: Status.hasBattery }
        Stat {
            id: batStat
            visible: Status.hasBattery
            label: "bat"
            // low-power / performance get a suffix; balanced stays quiet
            value: Status.batteryPercent + (Status.charging ? "+" : "")
                + (Status.powerProfile === "low-power" ? " eco"
                   : Status.powerProfile === "performance" ? " perf" : "")
            valueColor: Status.charging ? Theme.fujiWhite
                : Status.batteryPercent <= 15 ? Theme.waveRed
                : Status.batteryPercent <= 30 ? Theme.carpYellow
                : Theme.fujiWhite
            cursorShape: Qt.ArrowCursor
            hoverEnabled: true

            BatteryCard {
                anchorItem: batStat
                hovered: batStat.containsMouse
            }
        }

        Dot {}
        Stat {
            id: netStat
            label: "net"
            value: Status.network !== "" ? Status.network : "off"
            valueColor: Status.network !== "" ? Theme.fujiWhite : Theme.waveRed
            hoverEnabled: true
            onLeftClicked: Quickshell.execDetached(["ghostty", "-e", "nmtui"])

            NetCard {
                anchorItem: netStat
                hovered: netStat.containsMouse
            }
        }

        Dot {}
        Stat {
            // left click: netbird, right click: mullvad (same as the old waybar module)
            id: vpnStat
            label: "vpn"
            value: Status.vpnLabel
            valueColor: Status.vpnState === "connected" ? Theme.springGreen
                : Status.vpnState === "connecting" ? Theme.carpYellow
                : Theme.fujiGray
            hoverEnabled: true
            onLeftClicked: Status.toggleVpn("netbird")
            onRightClicked: Status.toggleVpn("mullvad")

            VpnCard {
                anchorItem: vpnStat
                hovered: vpnStat.containsMouse
            }
        }

        Dot {}
        Stat {
            label: ""
            value: Niri.layoutShort
            onLeftClicked: Niri.action(["switch-layout", "next"])
        }

        Dot {}
        // notifications: bell + count. Click: center, right-click: do-not-disturb
        Stat {
            label: ""
            value: (Notifs.dnd ? "󰂛" : "󰂚") + (Notifs.count > 0 ? " " + Notifs.count : "")
            valueColor: Notifs.dnd ? Theme.carpYellow
                : Notifs.centerOpen || Notifs.count > 0 ? Theme.fujiWhite
                : Theme.fujiGray
            onLeftClicked: Notifs.toggleCenter()
            onRightClicked: Notifs.dnd = !Notifs.dnd
        }

        Dot {}
        // idle inhibitor: coffee cup, yellow while the screen is kept awake
        Stat {
            label: ""
            value: Status.idleInhibited ? "󰅶" : "󰛊"
            valueColor: Status.idleInhibited ? Theme.carpYellow : Theme.fujiGray
            onLeftClicked: Status.idleInhibited = !Status.idleInhibited
        }

        Rule {
            anchors.verticalCenter: parent.verticalCenter
            visible: tray.count > 0
        }

        Tray {
            id: tray
            anchors.verticalCenter: parent.verticalCenter
            barWindow: bar
        }
    }
}
