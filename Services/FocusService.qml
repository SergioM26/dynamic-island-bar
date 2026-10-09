pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../Config"

Singleton {
    id: root

    property string previousAddress: ""
    property string hostMonitorName: ""
    property bool resettingSurface: false

    function capture(): void {
        restoreTimer.stop()
        remapTimer.stop()
        focusTimer.stop()
        root.resettingSurface = false
        root.previousAddress = Hyprland.activeToplevel?.address ?? ""
        root.hostMonitorName = Hyprland.focusedMonitor?.name ?? ""
    }

    function restore(): void {
        if (root.previousAddress.length === 0)
            return

        // A layer-shell surface can retain the real keyboard focus even after
        // its keyboard interactivity changes. Briefly lowering the host panel
        // releases that focus without removing its reserved screen area.
        root.resettingSurface = true
        remapTimer.restart()
    }

    function restoreDelayed(): void {
        if (root.previousAddress.length > 0)
            restoreTimer.restart()
    }

    function hold(): void {
        restoreTimer.stop()
        remapTimer.stop()
        focusTimer.stop()
        root.resettingSurface = false
    }

    function forget(): void {
        restoreTimer.stop()
        remapTimer.stop()
        focusTimer.stop()
        root.previousAddress = ""
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
            focusTimer.restart()
        }
    }

    Timer {
        id: focusTimer
        interval: 24
        onTriggered: {
            const address = root.previousAddress
            root.previousAddress = ""
            root.hostMonitorName = ""

            if (address.length > 0)
                Hyprland.dispatch("focuswindow address:" + address)
        }
    }
}
