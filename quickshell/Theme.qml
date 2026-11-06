pragma Singleton

import Quickshell
import QtQuick

// Tokyo Night (night), "refined": floating rounded surfaces, 1px borders,
// soft shadows. Blue is focus (matches niri's active border).
Singleton {
    // palette (names from folke/tokyonight.nvim)
    readonly property color bgDark: "#16161e"      // bar, cards
    readonly property color bg: "#1a1b26"
    readonly property color bgHighlight: "#292e42" // hover, dividers, empty tracks
    readonly property color bgVisual: "#283457"    // selection
    readonly property color gutter: "#3b4261"      // card borders
    readonly property color comment: "#565f89"     // decoration only: too dim for text
    readonly property color subtext: "#828bb8"     // muted text that must stay readable
    readonly property color fgDark: "#a9b1d6"      // secondary text, idle icons
    readonly property color fg: "#c0caf5"
    readonly property color blue: "#7aa2f7"
    readonly property color magenta: "#bb9af7"
    readonly property color green: "#9ece6a"
    readonly property color yellow: "#e0af68"
    readonly property color orange: "#ff9e64"
    readonly property color red: "#f7768e"

    readonly property color accent: blue

    // IBM Plex Sans for the interface (same as GTK/Qt), Martian Mono for
    // numbers (same as ghostty), nerd-font symbols for icons.
    readonly property string sans: "IBM Plex Sans"
    readonly property string mono: "MartianMono Nerd Font"
    readonly property string icons: "Symbols Nerd Font"
    readonly property string japanese: "IBM Plex Sans JP"

    readonly property int barSize: 38     // bar thickness, either orientation
    readonly property int gap: 10         // between floating surfaces and screen edges
    readonly property int inset: 14       // left/right padding inside cards
    readonly property int radius: 12      // cards, bar
    readonly property int radiusSmall: 8  // rows, buttons, pills
    // windows holding a card are this much bigger on each side, so the
    // card's shadow isn't cut off; the extra is masked out for input
    readonly property int shadowPad: 28
    readonly property int popupOffset: 14 // from a bar item to its hover card

    // nerd-font glyphs (Material Design set)
    readonly property var glyph: ({
        volume: ["\u{f057f}", "\u{f0580}", "\u{f057e}"], // low, medium, high
        volumeOff: "\u{f0581}",
        mic: "\u{f036c}",
        micOff: "\u{f036d}",
        brightness: "\u{f00df}",
        battery: ["\u{f007a}", "\u{f007b}", "\u{f007c}", "\u{f007d}", "\u{f007e}",
                  "\u{f007f}", "\u{f0080}", "\u{f0081}", "\u{f0082}", "\u{f0079}"], // 10..100
        batteryCharging: "\u{f0084}",
        wifi: "\u{f05a9}",
        wifiOff: "\u{f05aa}",
        ethernet: "\u{f0200}",
        vpnOn: "\u{f0565}",
        vpnOff: "\u{f0499}",
        bell: "\u{f009c}",
        bellBadge: "\u{f0178}",
        bellOff: "\u{f0a91}",
        awake: "\u{f0176}",
        sleepy: "\u{f06ca}",
        updates: "\u{f03d5}",
        linux: "\u{f033d}",
        play: "\u{f040a}",
        pause: "\u{f03e4}",
        search: "\u{f0349}",
        close: "\u{f0156}",
        lock: "\u{f033e}",
        checked: "\u{f0132}",
        unchecked: "\u{f0131}",
        radioOn: "\u{f043e}",
        radioOff: "\u{f043d}",
        expand: "\u{f0142}",
        collapse: "\u{f0140}",
    })

    readonly property var _digits: ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"]

    // 1..99 as kanji numerals: 3 → 三, 11 → 十一, 24 → 二十四
    function kanji(n) {
        if (n <= 0 || n > 99) return String(n);
        const tens = Math.floor(n / 10), ones = n % 10;
        return (tens > 1 ? _digits[tens] : "") + (tens > 0 ? "十" : "") + _digits[ones];
    }

    // explicit locales: the system one (en_DK) would turn the English Danish
    readonly property var _en: Qt.locale("en_GB")
    readonly property var _ja: Qt.locale("ja_JP")

    // 十一月三日 火曜日
    function kanjiDate(d) {
        return kanji(d.getMonth() + 1) + "月" + kanji(d.getDate()) + "日 " + d.toLocaleDateString(_ja, "dddd");
    }

    // Tue 3 Nov
    function englishDate(d) {
        return d.toLocaleDateString(_en, "ddd d MMM");
    }

    // Tuesday 3 November
    function englishDateLong(d) {
        return d.toLocaleDateString(_en, "dddd d MMMM");
    }

    // connected / connecting / anything else (VPN states)
    function stateColor(state) {
        return state === "connected" ? green
            : state === "connecting" || state === "disconnecting" ? yellow
            : subtext;
    }
}
