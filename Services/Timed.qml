// Timed.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    property date now : new Date()
    readonly property string time: Qt.formatTime(now, "HH:mm")
    readonly property string date : Qt.formatDate(now,"ddd dd MMM")

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: root.now = new Date()
    }
}
