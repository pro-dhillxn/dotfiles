// Quickshell — notifications.
//
// Quickshell IS the notification daemon here: this NotificationServer owns
// org.freedesktop.Notifications, so no separate notify daemon is needed.
// Incoming notifications are marked tracked (so they surface in
// trackedNotifications) and rendered as a stack in the top-right, below the bar.
// Each card auto-dismisses after its expiry (or 4 s minimum) / on click.
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import qs.services

Scope {
    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        actionsSupported: false
        onNotification: (notification) => {
            notification.tracked = true
        }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { top: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            implicitWidth: rep.count > 0 ? 360 : 0
            implicitHeight: rep.count > 0 ? Theme.barHeight + 8 + col.implicitHeight : 0
            visible: rep.count > 0

            Column {
                id: col
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: Theme.barHeight + 8
                anchors.rightMargin: 8
                spacing: 8
                Repeater {
                    id: rep
                    model: server.trackedNotifications
                    Rectangle {
                        id: card
                        required property var modelData   // a Notification
                        width: 344
                        height: 60
                        radius: 8
                        color: Theme.bg
                        border.width: 1
                        border.color: Theme.muted

                        // Auto-dismiss: honour the sender's expiry (ms), else 4 s;
                        // a 0 expiry means "persistent" -> keep an hour.
                        property bool _persistent: (modelData.expireTimeout ?? 0) === 0
                        Timer {
                            interval: card._persistent ? 3600000 : Math.max(4000, modelData.expireTimeout)
                            running: true
                            onTriggered: card.modelData.tracked = false
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 2
                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: card.modelData.appName
                                color: Theme.accent
                                font.family: Theme.font
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: card.modelData.summary
                                color: Theme.fg
                                font.family: Theme.font
                                font.pixelSize: 13
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: card.modelData.body.length > 0
                                elide: Text.ElideRight
                                text: card.modelData.body
                                color: Theme.muted
                                font.family: Theme.font
                                font.pixelSize: 12
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: card.modelData.tracked = false
                        }
                    }
                }
            }
        }
    }
}
