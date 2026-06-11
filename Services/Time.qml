// Time.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    property string time: Qt.formatTime(new Date(), "HH:mm")
    property string date : Qt.formatDate(new Date(), "ddd dd MMM")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.time = Qt.formatTime(new Date(), "HH:mm")
    }
}
