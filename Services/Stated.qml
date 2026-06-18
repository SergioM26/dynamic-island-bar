// Stated.qml
pragma Singleton

import Quickshell
// import QtQuick

Singleton {
    readonly property int idle : 0
    readonly property int volume : 1

    property int currentView : idle
}
