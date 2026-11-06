import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland
import qs
import qs.services

// A pill near the bottom of the screen, for a moment:
//  - levels: volume / mic / brightness as a bar
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
        hide.restart();
    }

    function showMedia() {
        if (!armed || !player || player.trackTitle === "") return;
        mode = "media";
        shown = true;
        hide.restart();
    }

    Timer {
        interval: 2000
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: hide
        interval: root.mode === "media" ? 3000 : 1500
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
    readonly property MprisPlayer player: Status.player

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
            margins.bottom: 40 - Theme.shadowPad
            exclusionMode: ExclusionMode.Ignore
            implicitWidth: pill.width + 2 * Theme.shadowPad
            implicitHeight: pill.height + 2 * Theme.shadowPad
            color: "transparent"
            mask: Region {}   // never takes input
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qs-osd"

            Card {
                id: pill
                x: Theme.shadowPad
                y: Theme.shadowPad
                width: root.mode === "media" ? 420 : 320
                height: root.mode === "media" ? 64 : 48
                radius: height / 2

                // -- level ------------------------------------------------
                RowLayout {
                    visible: root.mode === "level"
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 14

                    Icon {
                        Layout.preferredWidth: 18
                        horizontalAlignment: Text.AlignHCenter
                        text: root.kind === "lum" ? Theme.glyph.brightness
                            : root.kind === "mic" ? (root.muted ? Theme.glyph.micOff : Theme.glyph.mic)
                            : root.muted ? Theme.glyph.volumeOff
                            : Theme.glyph.volume[Math.min(2, Math.floor(root.level * 3))]
                        color: root.muted ? Theme.subtext : Theme.fg
                        font.pixelSize: 17
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 6
                        radius: 3
                        color: Theme.bgHighlight

                        Rectangle {
                            width: root.muted ? 0 : parent.width * root.level
                            height: parent.height
                            radius: 3
                            color: root.kind === "mic" ? Theme.yellow : Theme.accent
                            Behavior on width { NumberAnimation { duration: 90 } }
                        }
                    }

                    Mono {
                        Layout.preferredWidth: 28
                        horizontalAlignment: Text.AlignRight
                        text: root.muted ? "off" : Math.round(root.level * 100)
                        color: root.muted ? Theme.subtext : Theme.fg
                        font.pixelSize: 12
                    }
                }

                // -- media ------------------------------------------------
                RowLayout {
                    visible: root.mode === "media" && root.player !== null
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 24
                    spacing: 12

                    // play state in a tinted circle
                    Rectangle {
                        implicitWidth: 40
                        implicitHeight: 40
                        radius: 20
                        color: Qt.alpha(Theme.magenta, 0.16)

                        Icon {
                            anchors.centerIn: parent
                            text: root.player && root.player.isPlaying ? Theme.glyph.play : Theme.glyph.pause
                            color: Theme.magenta
                            font.pixelSize: 18
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 1

                        Label {
                            width: parent.width
                            elide: Text.ElideRight
                            text: root.player ? root.player.trackTitle : ""
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }
                        Label {
                            width: parent.width
                            visible: text !== ""
                            elide: Text.ElideRight
                            text: root.player ? root.player.trackArtist : ""
                            color: Theme.fgDark
                        }
                    }

                    Label {
                        text: root.player ? root.player.identity : ""
                        color: Theme.subtext
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
