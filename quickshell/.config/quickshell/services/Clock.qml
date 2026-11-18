// Quickshell — clock service. Re-formats whenever the SystemClock ticks.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    property string time: Qt.formatDateTime(_clock.date, "ddd MMM dd - HH:mm")
    SystemClock {
        id: _clock
        precision: SystemClock.Minutes
    }
}
