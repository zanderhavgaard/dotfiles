import QtQuick

// Text in the house font. Plain text by default: most of what's shown comes
// from outside (SSIDs, track titles, app names), so markup is opt-in
// (textFormat: Text.StyledText) where it's actually meant.
Text {
    color: Theme.fujiWhite
    font.family: Theme.mono
    font.pixelSize: 11
    textFormat: Text.PlainText
}
