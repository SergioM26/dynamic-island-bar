pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../Config"

Singleton {
    id: root

    property string hostMonitorName: ""
    property bool resettingSurface: false

    function capture(): void {
        restoreTimer.stop()
        remapTimer.stop()
        root.resettingSurface = false
        root.hostMonitorName = Hyprland.focusedMonitor?.name ?? ""
    }

    function restore(): void {
        if (root.hostMonitorName.length === 0)
            return

        // A layer-shell surface can retain the real keyboard focus even after
        // its keyboard interactivity changes. Briefly lowering the host panel
        // releases that focus without removing its reserved screen area.
        root.resettingSurface = true
        remapTimer.restart()
    }

    function restoreDelayed(): void {
        if (root.hostMonitorName.length > 0)
            restoreTimer.restart()
    }

    function hold(): void {
        restoreTimer.stop()
        remapTimer.stop()
        root.resettingSurface = false
    }

    function forget(): void {
        restoreTimer.stop()
        remapTimer.stop()
        root.hostMonitorName = ""
        root.resettingSurface = false
    }

    Timer {
        id: restoreTimer
        interval: Theme.contentTransitionDuration + Theme.morphDuration + 30
        onTriggered: root.restore()
    }

    Timer {
        id: remapTimer
        interval: 24
        onTriggered: {
            root.resettingSurface = false
            root.hostMonitorName = ""
        }
    }
}
