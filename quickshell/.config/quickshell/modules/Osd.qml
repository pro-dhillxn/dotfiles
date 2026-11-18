// Quickshell — volume OSD (on-screen display).
//
// Full-screen transparent overlay (exclusionMode Ignore -> reserves no space,
// and scale is 1.0 so the Ignore bug #1346 does not apply). A Region limits
// input to the pill, so the rest of the screen stays click-through. Shown on
// any change to the default sink's volume/mute, auto-hides after 1.6 s.
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.services

Variants {
    model: Quickshell.screens
    PanelWindow {
        required property var modelData
        screen: modelData
        anchors { top: true; left: true; right: true; bottom: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        visible: shown

        // --- reactive state ---
        property bool shown: false
        property real vol: Audio.volume
        property bool muted: Audio.muted

        // Ignore changes until armed so the boot-time 0 -> real-volume jump
        // does not flash the OSD.
        property bool _armed: false
        Timer { id: _arm; interval: 2500; running: true; onTriggered: { _armed = true; stop() } }

        onVolChanged:     { if (_armed) flash() }
        onMutedChanged:   { if (_armed) flash() }

        function flash() {
            shown = true
            _hide.restart()
        }
        Timer { id: _hide; interval: 1600; repeat: false; onTriggered: shown = false }

        // --- pill ---
        Item {
            id: pill
            anchors.centerIn: parent
            width: 240
            height: 44

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: Theme.bg
                border.width: 1
                border.color: Theme.muted
            }
            RowLayout {
                anchors.centerIn: parent
                spacing: 10
                Text {
                    text: (muted || vol <= 0) ? "\uf06c" : (vol < 0.5 ? "\uf027" : "\uf028")
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: 16
                }
                Rectangle {
                    id: track
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    height: 6
                    radius: 3
                    color: Theme.muted
                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: (muted ? 0 : vol) * parent.width
                        height: parent.height
                        radius: 3
                        color: Theme.accent
                    }
                }
                Text {
                    text: muted ? "muted" : Math.round(vol * 100) + "%"
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: 12
                }
            }
        }

        // Only the pill is interactive; everything else passes clicks through.
        Region { item: pill }
    }
}
