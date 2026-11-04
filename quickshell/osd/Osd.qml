import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland
import qs
import qs.services

// Popups that sit just above the bar for a moment:
//  - levels: VOL / MIC / LUM as 20 segments
//  - media: play state + track when the player changes track or pauses
// Volume and mic are watched directly. Brightness has no change signal, so
// niri's brightness binds call `qs ipc call osd brightness` after brightnessctl.
Scope {
    id: root

    property string mode: "level"   // level | media
    property string kind: "vol"
    property real level: 0
    property bool muted: false
    property bool shown: false
    property bool armed: false   // ignore the initial syncs at startup

    function showLevel(k, v, m) {
        if (!armed) return;
        mode = "level";
        kind = k;
        level = Math.max(0, Math.min(1, v));
        muted = m;
        shown = true;
        hide.interval = 1500;
        hide.restart();
    }

    function showMedia() {
        if (!armed || !player || player.trackTitle === "") return;
        mode = "media";
        shown = true;
        hide.interval = 3000;
        hide.restart();
    }

    Timer {
        interval: 2000
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: hide
        interval: 1500
        onTriggered: root.shown = false
    }

    // ---- levels ----------------------------------------------------------
    Connections {
        target: Status.audioReady ? Status.sink.audio : null
        function onVolumeChanged() { root.showLevel("vol", Status.volume, Status.muted); }
        function onMutedChanged() { root.showLevel("vol", Status.volume, Status.muted); }
    }

    Connections {
        target: Status.micReady ? Status.source.audio : null
        function onVolumeChanged() { root.showLevel("mic", Status.micVolume, Status.micMuted); }
        function onMutedChanged() { root.showLevel("mic", Status.micVolume, Status.micMuted); }
    }

    // Status.brightness only changes on a real change; the poll and the
    // ipc refresh both land here.
    Connections {
        target: Status
        function onBrightnessChanged() {
            if (Status.brightness >= 0) root.showLevel("lum", Status.brightness / 100, false);
        }
    }

    IpcHandler {
        target: "osd"
        function brightness(): void { Status.refreshBrightness(); }
        function media(): void { root.showMedia(); }
    }

    // ---- media -----------------------------------------------------------
    // the player to report on: whichever is playing, else the first one
    readonly property MprisPlayer player: {
        // playerctld is a proxy that mirrors another player; skip it
        const ps = Mpris.players.values.filter(p => !p.dbusName.includes("playerctld"));
        return ps.find(p => p.isPlaying) ?? ps[0] ?? null;
    }

    onPlayerChanged: showMedia()

    Connections {
        target: root.player
        function onTrackTitleChanged() { root.showMedia(); }
        function onIsPlayingChanged() { root.showMedia(); }
    }

    // ---- window ----------------------------------------------------------
    LazyLoader {
        active: root.shown

        PanelWindow {
            anchors.bottom: true
            margins.bottom: 12
            // Normal + zone 0: stay out of the bar's reserved strip
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: 0
            implicitWidth: root.mode === "media" ? 440 : 300
            implicitHeight: root.mode === "media" ? 56 : 38
            color: "transparent"
            mask: Region {}
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qs-osd"

            Rectangle {
                anchors.fill: parent
                color: Theme.sumiInk0
                border.width: 1
                border.color: Theme.sumiInk6

                // -- level ------------------------------------------------
                Row {
                    visible: root.mode === "level"
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    Text {
                        id: label
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.kind
                        color: Theme.mutedText
                        font.family: Theme.mono
                        font.pixelSize: 11
                        font.letterSpacing: 1
                        font.capitalization: Font.AllUppercase
                    }

                    // 20 segments, filled up to the level
                    Row {
                        id: segments
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - label.width - value.width - 2 * parent.spacing
                        spacing: 3

                        Repeater {
                            model: 20
                            Rectangle {
                                required property int index
                                width: (segments.width - 19 * segments.spacing) / 20
                                height: 10
                                color: !root.muted && index < Math.round(root.level * 20)
                                    ? Theme.fujiWhite : Theme.sumiInk5
                            }
                        }
                    }

                    Text {
                        id: value
                        anchors.verticalCenter: parent.verticalCenter
                        width: 34
                        horizontalAlignment: Text.AlignRight
                        text: root.muted ? "off" : Math.round(root.level * 100)
                        color: root.muted ? Theme.fujiGray : Theme.fujiWhite
                        font.family: Theme.mono
                        font.pixelSize: 11
                        font.capitalization: Font.AllUppercase
                    }
                }

                // -- media ------------------------------------------------
                Item {
                    visible: root.mode === "media" && root.player !== null
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14

                    Text {
                        id: playState
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18
                        text: root.player && root.player.isPlaying ? "▶" : "‖"
                        color: Theme.springGreen
                        font.family: Theme.mono
                        font.pixelSize: 13
                    }

                    Column {
                        anchors {
                            left: playState.right
                            leftMargin: 10
                            right: source.left
                            rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 2

                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: root.player ? root.player.trackTitle : ""
                            textFormat: Text.PlainText    // from outside: no markup
                            color: Theme.fujiWhite
                            font.family: Theme.mono
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                        Text {
                            width: parent.width
                            visible: text !== ""
                            elide: Text.ElideRight
                            text: root.player ? root.player.trackArtist : ""
                            textFormat: Text.PlainText    // from outside: no markup
                            color: Theme.oldWhite
                            font.family: Theme.mono
                            font.pixelSize: 11
                        }
                    }

                    Text {
                        id: source
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.player ? root.player.identity : ""
                        textFormat: Text.PlainText    // from outside: no markup
                        color: Theme.mutedText
                        font.family: Theme.mono
                        font.pixelSize: 10
                        font.letterSpacing: 1
                        font.capitalization: Font.AllUppercase
                    }
                }
            }
        }
    }
}
