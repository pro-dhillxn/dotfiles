// Quickshell — top bar (one per monitor).
// Core set: workspaces, active window title, clock, volume.
// (Battery was in scope but this box has no battery / UPower, so it's omitted.)
import Quickshell
import QtQuick
import Quickshell.Hyprland
import QtQuick.Layouts
import qs.services

Variants {
    model: Quickshell.screens
    PanelWindow {
        required property var modelData
        screen: modelData
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: Theme.barHeight
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Theme.bgTranslucent
        }

        // --- Left: workspaces + title ---
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: parent.center
            anchors.rightMargin: 60
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Repeater {
                model: Hyprland.workspaces.values
                Rectangle {
                    required property var modelData
                    visible: !String(modelData.name).startsWith("special")
                    implicitWidth: 26
                    implicitHeight: 20
                    radius: 5
                    Layout.alignment: Qt.AlignVCenter
                    color: modelData.focused ? Theme.accent : modelData.active ? "#3b4261" : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: modelData.name
                        color: modelData.focused ? Theme.bg : Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hypr.focusWorkspace(modelData.name)
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                elide: Text.ElideRight
                text: Hyprland.activeToplevel?.title ?? ""
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }
        }

        // --- Center: clock ---
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: Clock.time
            color: Theme.accent
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            font.bold: true
        }

        // --- Right: volume ---
        RowLayout {
            id: volRow
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3
            property real _vol: Audio.volume
            property bool _mute: Audio.muted
            Text {
                text: (volRow._mute || volRow._vol <= 0) ? "\uf06c" : (volRow._vol < 0.5 ? "\uf027" : "\uf028")
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }
            Text {
                text: Math.round(volRow._vol * 100) + "%"
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }
        }
    }
}
