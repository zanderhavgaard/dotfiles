pragma Singleton

import Quickshell
import QtQuick

// Kanagawa Wave, laid out Paper-style: square corners, 1px rules, no shadows.
// Green is reserved for focus (matches niri's border active-color).
Singleton {
    // palette (names from rebelot/kanagawa.nvim)
    readonly property color sumiInk0: "#16161D"   // bar, cards
    readonly property color sumiInk1: "#181820"
    readonly property color sumiInk3: "#1F1F28"   // window background
    readonly property color sumiInk4: "#2A2A37"   // inner rules
    readonly property color sumiInk5: "#363646"   // outer rules
    readonly property color sumiInk6: "#54546D"   // card borders
    readonly property color waveBlue1: "#223249"
    readonly property color waveBlue2: "#2D4F67"  // selection
    readonly property color fujiWhite: "#DCD7BA"  // text
    readonly property color oldWhite: "#C8C093"   // secondary text
    readonly property color fujiGray: "#727169"   // labels, empty things
    readonly property color mutedText: "#a09d8a"  // small labels that must stay readable
    readonly property color springGreen: "#98BB6C"
    readonly property color crystalBlue: "#7E9CD8"
    readonly property color carpYellow: "#E6C384"
    readonly property color surimiOrange: "#FFA066"
    readonly property color waveRed: "#E46876"
    readonly property color waveAqua: "#7AA89F"

    readonly property color focus: springGreen

    // type: IBM Plex Mono (nerd-font patched, so icons work) for everything
    // latin, Shippori Mincho (ttf-shippori-mincho, AUR) for the kanji.
    readonly property string mono: "BlexMono Nerd Font"
    readonly property string serif: "Shippori Mincho"

    readonly property int barHeight: 32
    readonly property int gap: 10      // between floating surfaces and screen edges
    readonly property int inset: 14    // left/right padding inside cards

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
        return state === "connected" ? springGreen
            : state === "connecting" || state === "disconnecting" ? carpYellow
            : fujiGray;
    }
}
