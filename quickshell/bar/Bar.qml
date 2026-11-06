import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// A floating, rounded bar along the top edge.
//   workspaces · column map · kernel · updates ... date time ... media · status · tray
PanelWindow {
    id: bar

    required property ShellScreen modelData

    readonly property string output: modelData.name
    // window-bound things (the idle inhibitor) live on one bar only
    readonly property bool primary: modelData === Quickshell.screens[0]

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    // the card plus the gap above it; the window reaches Theme.shadowPad
    // further for the shadow, which is outside the input mask
    exclusiveZone: Theme.gap + Theme.barSize
    implicitHeight: Theme.gap + Theme.barSize + Theme.shadowPad
    color: "transparent"
    mask: Region { item: card }
    WlrLayershell.namespace: "qs-bar"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // compositor only honours this while the bar is visible, which it always is
    IdleInhibitor {
        window: bar
        enabled: bar.primary && Status.idleInhibited
    }

    component Divider: Rectangle {
        Layout.leftMargin: 6
        Layout.rightMargin: 6
        implicitWidth: 1
        implicitHeight: 16
        color: Theme.gutter
    }

    Card {
        id: card
        x: Theme.gap
        y: Theme.gap
        width: bar.width - 2 * Theme.gap
        height: Theme.barSize

        // ---- left: workspaces, column map, kernel, updates ---------------
        RowLayout {
            anchors {
                left: parent.left
                leftMargin: 7
                verticalCenter: parent.verticalCenter
            }
            spacing: 2

            Workspaces {
                output: bar.output
            }

            ColumnMap {
                Layout.leftMargin: 10
                output: bar.output
                outputWidth: bar.screen.width
            }

            Divider {}

            // "reboot" in yellow once linux was upgraded under the running kernel
            Module {
                icon: Theme.glyph.linux
                iconColor: Status.kernelStale ? Theme.yellow : Theme.subtext
                text: Status.kernelStale ? "reboot" : Status.kernel
                textColor: Status.kernelStale ? Theme.yellow : Theme.subtext
                cursorShape: Qt.ArrowCursor
            }

            // hover: the package list; click: paru
            Module {
                id: updates
                visible: Status.updates > 0
                icon: Theme.glyph.updates
                iconColor: Theme.orange
                text: Status.updates
                onLeftClicked: Status.runUpdates()

                UpdatesCard { anchorItem: updates }
            }
        }

        // ---- middle: date + time -------------------------------------------
        // click switches the date between Tue 3 Nov and 十一月三日 火曜日,
        // hover shows the world clock
        MouseArea {
            id: clockArea
            anchors.centerIn: parent
            implicitWidth: dateTime.implicitWidth + 16
            implicitHeight: Theme.barSize - 12
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Status.japaneseDate = !Status.japaneseDate

            WorldClock { anchorItem: clockArea }

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSmall
                color: Theme.bgHighlight
                opacity: clockArea.containsMouse ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            Row {
                id: dateTime
                anchors.centerIn: parent
                spacing: 10

                Label {
                    anchors.baseline: time.baseline
                    text: Status.japaneseDate ? Theme.kanjiDate(clock.date) : Theme.englishDate(clock.date)
                    color: Theme.fgDark
                    font.family: Status.japaneseDate ? Theme.japanese : Theme.sans
                    font.pixelSize: 13
                }
                Mono {
                    id: time
                    text: Qt.formatTime(clock.date, "hh:mm")
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }
            }
        }

        // ---- right: media, status, tray --------------------------------------
        RowLayout {
            anchors {
                right: parent.right
                rightMargin: 7
                verticalCenter: parent.verticalCenter
            }
            spacing: 2

            MediaRing {
                Layout.rightMargin: 6
            }

            // click: mute toggle, scroll: level. A live mic is yellow so it's noticed.
            Module {
                id: mic
                icon: Status.micMuted ? Theme.glyph.micOff : Theme.glyph.mic
                iconColor: Status.micMuted ? Theme.subtext : Theme.yellow
                text: Status.micMuted ? "" : Math.round(Status.micVolume * 100)
                onLeftClicked: Status.toggleMuted(Status.source)
                onRightClicked: Quickshell.execDetached(["pwvucontrol"])
                onScrolled: steps => Status.stepVolume(Status.source, steps)

                AudioCard {
                    anchorItem: mic
                    node: Status.source
                    input: true
                }
            }

            Module {
                id: vol
                icon: Status.muted ? Theme.glyph.volumeOff
                    : Theme.glyph.volume[Math.min(2, Math.floor(Status.volume * 3))]
                iconColor: Status.muted ? Theme.subtext : Theme.fgDark
                text: Status.muted ? "" : Math.round(Status.volume * 100)
                onLeftClicked: Quickshell.execDetached(["pwvucontrol"])
                onRightClicked: Status.toggleMuted(Status.sink)
                onScrolled: steps => Status.stepVolume(Status.sink, steps)

                AudioCard {
                    anchorItem: vol
                    node: Status.sink
                }
            }

            Module {
                visible: Status.brightness >= 0
                icon: Theme.glyph.brightness
                text: Status.brightness
                cursorShape: Qt.ArrowCursor
                onScrolled: steps => Status.stepBrightness(steps)
            }

            Module {
                id: bat
                visible: Status.hasBattery
                readonly property color level: Status.charging ? Theme.green
                    : Status.batteryPercent <= 15 ? Theme.red
                    : Status.batteryPercent <= 30 ? Theme.yellow
                    : Theme.fgDark
                icon: Status.charging ? Theme.glyph.batteryCharging
                    : Theme.glyph.battery[Math.max(0, Math.min(9, Math.ceil(Status.batteryPercent / 10) - 1))]
                iconColor: level
                // low-power / performance get a suffix; balanced stays quiet
                text: Status.batteryPercent
                    + (Status.powerProfile === "low-power" ? " eco"
                       : Status.powerProfile === "performance" ? " perf" : "")
                textColor: Status.batteryPercent <= 30 && !Status.charging ? level : Theme.fg
                cursorShape: Qt.ArrowCursor

                BatteryCard { anchorItem: bat }
            }

            Module {
                id: net
                icon: Status.network === "" ? Theme.glyph.wifiOff
                    : Status.netDevice.startsWith("e") ? Theme.glyph.ethernet
                    : Theme.glyph.wifi
                iconColor: Status.network === "" ? Theme.red : Theme.fgDark
                // the connection (wifi) name, cut short if it's long
                text: Status.network.length > 20 ? Status.network.slice(0, 19) + "…" : Status.network
                onLeftClicked: Status.inTerminal(["nmtui"])

                NetCard { anchorItem: net }
            }

            // left click: netbird, right click: mullvad
            Module {
                id: vpn
                icon: Status.vpnState === "disconnected" ? Theme.glyph.vpnOff : Theme.glyph.vpnOn
                iconColor: Theme.stateColor(Status.vpnState)
                // which are up (or coming up): NB, MV, NB+MV; nothing when off
                text: Status.vpnLabel === "off" ? ""
                    : Status.vpnLabel.replace("netbird", "NB").replace("mullvad", "MV")
                textColor: Theme.stateColor(Status.vpnState)
                onLeftClicked: Status.toggleVpn("netbird")
                onRightClicked: Status.toggleVpn("mullvad")

                VpnCard { anchorItem: vpn }
            }

            Module {
                text: Niri.layoutShort
                textColor: Theme.fgDark
                onLeftClicked: Niri.action(["switch-layout", "next"])
            }

            // notifications. Click: center, right-click: do-not-disturb
            Module {
                icon: Notifs.dnd ? Theme.glyph.bellOff : Notifs.count > 0 ? Theme.glyph.bellBadge : Theme.glyph.bell
                iconColor: Notifs.dnd ? Theme.yellow
                    : Notifs.centerOpen || Notifs.count > 0 ? Theme.fg
                    : Theme.fgDark
                text: Notifs.count > 0 ? Notifs.count : ""
                onLeftClicked: Notifs.toggleCenter()
                onRightClicked: Notifs.dnd = !Notifs.dnd
            }

            // idle inhibitor: yellow while the screen is kept awake
            Module {
                icon: Status.idleInhibited ? Theme.glyph.awake : Theme.glyph.sleepy
                iconColor: Status.idleInhibited ? Theme.yellow : Theme.subtext
                onLeftClicked: Status.idleInhibited = !Status.idleInhibited
            }

            Divider { visible: tray.count > 0 }

            Tray {
                id: tray
                Layout.rightMargin: 6
            }
        }
    }
}
