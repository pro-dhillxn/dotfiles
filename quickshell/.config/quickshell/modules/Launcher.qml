// Quickshell — app launcher.
//
// Fuzzy-filters apps via DesktopEntries (built-in singleton).
// ScriptModel provides reactive filtering. Layer shell overlay window.
// Toggled via IpcHandler in shell.qml.
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.services

Scope {
    id: launcher

    property bool open: false

    function toggle() {
        launcher.open = !launcher.open;
    }

    function _launch(entry) {
        launcher.open = false;
        entry.execute();
    }

    // Resolve a desktop-entry icon (theme name or absolute path) to an Image source.
    function _iconSource(icon) {
        const fallback = "application-x-executable";
        if (!icon || icon.length === 0)
            return Quickshell.iconPath(fallback);
        if (icon.startsWith("/"))
            return "file://" + icon;
        return Quickshell.iconPath(icon, fallback);
    }

    // --- The window (layer shell overlay — not a managed toplevel) ---
    PanelWindow {
        id: popup
        visible: launcher.open
        WlrLayershell.namespace: "qs-launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        focusable: true
        implicitWidth: 520
        implicitHeight: 460
        color: Theme.bg

        HyprlandFocusGrab {
            windows: [popup]
            active: popup.visible
            onCleared: launcher.open = false
        }

        onVisibleChanged: v => {
            if (v) {
                tf.text = "";
                tf.forceActiveFocus();
            }
        }

        ColumnLayout {
            id: rootLayout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            focus: true

            // --- Keyboard handling ---
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (list.count > 0) {
                        let idx = list.currentIndex >= 0 ? list.currentIndex : 0;
                        let entry = list.model.values[idx];
                        if (entry)
                            launcher._launch(entry);
                    }
                    event.accepted = true;
                } else if (event.key === Qt.Key_Escape) {
                    launcher.open = false;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down) {
                    if (list.count > 0) {
                        list.currentIndex = Math.min(list.currentIndex + 1, list.count - 1);
                        list.positionViewAtIndex(list.currentIndex, ListView.Contain);
                    }
                    event.accepted = true;
                } else if (event.key === Qt.Key_Up) {
                    if (list.count > 0) {
                        list.currentIndex = Math.max(list.currentIndex - 1, 0);
                        list.positionViewAtIndex(list.currentIndex, ListView.Contain);
                    }
                    event.accepted = true;
                }
            }

            // --- Search field ---
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                radius: 8
                color: "#24283b"
                border.width: 1
                border.color: tf.activeFocus ? Theme.accent : Theme.muted

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 6

                    Text {
                        text: "\uf002"
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 14
                    }

                    TextField {
                        id: tf
                        Layout.fillWidth: true
                        background: null
                        color: Theme.fg
                        placeholderText: "Search applications…"
                        placeholderTextColor: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 14

                        // Keep the selection on the best match as the query changes
                        onTextChanged: {
                            list.currentIndex = 0;
                            list.positionViewAtBeginning();
                        }
                    }
                }
            }

            // --- App list ---
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "transparent"
                border.width: 1
                border.color: Theme.muted
                clip: true

                ListView {
                    id: list
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 2
                    clip: true
                    model: ScriptModel {
                        values: {
                            const q = tf.text.trim().toLowerCase();
                            return [...DesktopEntries.applications.values].filter(e => !e.noDisplay).filter(e => {
                                if (q === "")
                                    return true;
                                return launcher._fuzzy(q, e.name.toLowerCase());
                            }).sort((a, b) => a.name.localeCompare(b.name));
                        }
                    }
                    highlight: Rectangle {
                        color: "#2d3352"
                        radius: 6
                    }
                    highlightMoveDuration: 80
                    delegate: Item {
                        id: row
                        required property var modelData
                        required property int index

                        width: list.width
                        height: 40

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 12

                            // Real icon (replaces the raw icon-name text that overlapped the name)
                            Image {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                Layout.alignment: Qt.AlignVCenter
                                sourceSize.width: 48
                                sourceSize.height: 48
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                smooth: true
                                source: launcher._iconSource(row.modelData.icon)
                            }

                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: row.modelData.name
                                color: Theme.fg
                                font.family: Theme.font
                                font.pixelSize: 13
                            }

                            // Short description instead of the raw Exec string
                            Text {
                                visible: text.length > 0
                                Layout.maximumWidth: 150
                                elide: Text.ElideRight
                                text: row.modelData.genericName
                                color: Theme.muted
                                font.family: Theme.font
                                font.pixelSize: 11
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: list.currentIndex = row.index
                            onClicked: launcher._launch(row.modelData)
                        }
                    }
                }
            }
        }
    }

    // --- Fuzzy match (subsequence, case-insensitive) ---
    function _fuzzy(query, text) {
        if (query.length === 0)
            return true;
        let qi = 0;
        for (let ti = 0; ti < text.length && qi < query.length; ti++) {
            if (text[ti] === query[qi])
                qi++;
        }
        return qi === query.length;
    }
}
