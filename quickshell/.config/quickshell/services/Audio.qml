// Quickshell — Audio service: reactive default-sink volume/mute.
//
// Quickshell 0.3.2's Pipewire service keeps nodes UNBOUND by default — an
// unbound node only exposes a subset of its state, and `audio.volume` stays
// at its initial 0 until the node is bound. Binding is refcounted: QML must
// hold the node in a PwObjectTracker for the service to bind it and stream
// its volume/mute updates (see the "Object Binding" section of the
// Quickshell.Services.Pipewire docs).
//
// This singleton is the single owner of that tracker, so every module reads
// Audio.volume / Audio.muted instead of touching Pipewire directly.
pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    // Bind (ref) the current default sink. Re-evaluates whenever the default
    // sink changes, so the tracker follows it and the old sink unbinds.
    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
    readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false
}
