// Quickshell — shell entry point.
//
// Loads the core shell: top bar, volume OSD, notifications, and the app launcher.
// IpcHandler is declared FIRST (before any window) per Quickshell #1411.
import Quickshell
import Quickshell.Io
import qs.modules

ShellRoot {
    // Must be declared before any window (Quickshell #1411).
    IpcHandler {
        target: "launcher"
        function toggle() {
            launcher.toggle();
        }
    }

    Launcher {
        id: launcher
    }
    Bar {}
    Osd {}
    Notifs {}
}
