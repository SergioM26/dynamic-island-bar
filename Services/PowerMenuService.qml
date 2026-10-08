pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../Config"

Singleton {
    id: root

    property bool visible: false
    property bool confirming: false
    property bool compact: false
    property string hostMonitorName: ""
    property var pendingCommand: []

    function showMenu(): void {
        root.confirming = false
        root.compact = false
        root.hostMonitorName = Hyprland.focusedMonitor?.name ?? ""
        root.visible = true
    }

    function closeMenu(): void {
        root.confirming = false
        root.compact = false
        compactDelay.stop()
        root.visible = false
    }

    function beginConfirmation(): void {
        root.confirming = true
        root.compact = false
        compactDelay.restart()
    }

    function toggleMenu(): void {
        if (root.visible)
            root.closeMenu()
        else
            root.showMenu()
    }

    function commit(action: string): void {
        switch (action) {
        case "poweroff":
            root.pendingCommand = ["systemctl", "poweroff"]
            break
        case "suspend":
            root.pendingCommand = ["systemctl", "suspend"]
            break
        case "lock":
            root.pendingCommand = ["hyprlock"]
            break
        case "reboot":
            root.pendingCommand = ["systemctl", "reboot"]
            break
        default:
            return
        }

        root.visible = false
        commandDelay.restart()
    }

    IpcHandler {
        target: "powerMenu"

        function toggle(): void { root.toggleMenu() }
        function open(): void { root.showMenu() }
        function close(): void { root.closeMenu() }
    }

    Timer {
        id: compactDelay
        interval: Theme.optionCenterDuration
        onTriggered: root.compact = root.confirming
    }

    Timer {
        id: commandDelay
        interval: Theme.contentTransitionDuration + Theme.morphDuration
        onTriggered: {
            if (root.pendingCommand.length > 0)
                Quickshell.execDetached(root.pendingCommand)

            root.pendingCommand = []
            root.confirming = false
            root.compact = false
        }
    }
}
