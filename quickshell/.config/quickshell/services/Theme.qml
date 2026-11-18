// Quickshell — shared theme.
// Central palette + font so the modules stay consistent. Tokyo Night,
// matching the existing bar.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property color bg: "#1a1b26"
    readonly property color bgTranslucent: Qt.rgba(bg.r, bg.g, bg.b, 0.9)
    readonly property color fg: "#a9b1d6"
    readonly property color muted: "#444b6a"
    readonly property color accent: "#7aa2f7"
    readonly property color cyan: "#0db9d7"
    readonly property color yellow: "#e0af68"

    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 14
    readonly property int barHeight: 30
}
