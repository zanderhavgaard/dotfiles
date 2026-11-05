import QtQuick
import QtQuick.Layouts
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
    readonly property bool primary: modelData === Quickshell.screens[0]

    screen: modelData
    anchors {
        left: true
        right: true
        bottom: true
    }
    implicitHeight: Theme.barHeight
    color: Theme.sumiInk0

    component Dot: Mono {
        text: "·"
        color: Theme.fujiGray
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
    RowLayout {
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

        Rule {}

        RowLayout {
            spacing: 8

            // yellow + "reboot" once linux was upgraded under the running kernel
            Stat {
                label: "krn"
                value: Status.kernel + (Status.kernelStale ? " reboot" : "")
                valueColor: Status.kernelStale ? Theme.carpYellow : Theme.oldWhite
                cursorShape: Qt.ArrowCursor
            }

            Dot { visible: updatesStat.visible }
            // hover: the package list; click: paru
            Stat {
                id: updatesStat
                visible: Status.updates > 0
                value: "↑" + Status.updates
                valueColor: Theme.surimiOrange
                onLeftClicked: Status.runUpdates()

                UpdatesCard { anchorItem: updatesStat }
            }
        }
    }

    // ---- right: date + time, status, tray ----------------------------------
    RowLayout {
        id: right
        anchors {
            right: parent.right
            rightMargin: 12
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        // date + time; click switches the date between Tue 3 Nov and 十一月三日 火曜日,
        // hover shows the world clock
        MouseArea {
            id: clockArea
            implicitWidth: dateTime.implicitWidth
            implicitHeight: dateTime.implicitHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Status.japaneseDate = !Status.japaneseDate

            WorldClock { anchorItem: clockArea }

            Row {
                id: dateTime
                spacing: 10

                Mono {
                    anchors.baseline: time.baseline
                    text: Status.japaneseDate ? Theme.kanjiDate(clock.date) : Theme.englishDate(clock.date)
                    color: Theme.oldWhite
                    font.family: Status.japaneseDate ? Theme.serif : Theme.mono
                    font.pixelSize: 13
                }
                Mono {
                    id: time
                    text: Qt.formatTime(clock.date, "hh:mm")
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }
        }

        Rule {}

        // click: mute toggle, scroll: level. Live mic is yellow so it's noticed.
        Stat {
            id: micStat
            label: "mic"
            value: Status.micMuted ? "off" : Math.round(Status.micVolume * 100)
            valueColor: Status.micMuted ? Theme.fujiGray : Theme.carpYellow
            onLeftClicked: Status.toggleMuted(Status.source)
            onRightClicked: Quickshell.execDetached(["pwvucontrol"])
            onScrolled: steps => Status.stepVolume(Status.source, steps)

            AudioCard {
                anchorItem: micStat
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
            onRightClicked: Status.toggleMuted(Status.sink)
            onScrolled: steps => Status.stepVolume(Status.sink, steps)

            AudioCard {
                anchorItem: volStat
                node: Status.sink
            }
        }

        Dot { visible: lumStat.visible }
        Stat {
            id: lumStat
            visible: Status.brightness >= 0
            label: "lum"
            value: Status.brightness
            onScrolled: steps => Status.stepBrightness(steps)
        }

        Dot { visible: batStat.visible }
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

            BatteryCard { anchorItem: batStat }
        }

        Dot {}
        Stat {
            id: netStat
            label: "net"
            value: Status.network !== "" ? Status.network : "off"
            valueColor: Status.network !== "" ? Theme.fujiWhite : Theme.waveRed
            onLeftClicked: Status.inTerminal(["nmtui"])

            NetCard { anchorItem: netStat }
        }

        Dot {}
        Stat {
            // left click: netbird, right click: mullvad (same as the old waybar module)
            id: vpnStat
            label: "vpn"
            value: Status.vpnLabel
            valueColor: Theme.stateColor(Status.vpnState)
            onLeftClicked: Status.toggleVpn("netbird")
            onRightClicked: Status.toggleVpn("mullvad")

            VpnCard { anchorItem: vpnStat }
        }

        Dot {}
        Stat {
            value: Niri.layoutShort
            onLeftClicked: Niri.action(["switch-layout", "next"])
        }

        Dot {}
        // notifications: bell + count. Click: center, right-click: do-not-disturb
        Stat {
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
            value: Status.idleInhibited ? "󰅶" : "󰛊"
            valueColor: Status.idleInhibited ? Theme.carpYellow : Theme.fujiGray
            onLeftClicked: Status.idleInhibited = !Status.idleInhibited
        }

        Rule { visible: tray.count > 0 }

        Tray { id: tray }
    }
}
