pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../Config"

Singleton {
    id: root

    property bool visible: false
    property string hostMonitorName: ""
    property var pendingCommand: []

    function showMenu(): void {
        root.hostMonitorName = Hyprland.focusedMonitor?.name ?? ""
        root.visible = true
    }

    function closeMenu(): void {
        root.visible = false
    }

    function toggleMenu(): void {
        if (root.visible)
            root.closeMenu()
        else
            root.showMenu()
    }

    function trigger(action: string): void {
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

        root.closeMenu()
        commandDelay.restart()
    }

    IpcHandler {
        target: "powerMenu"

        function toggle(): void { root.toggleMenu() }
        function open(): void { root.showMenu() }
        function close(): void { root.closeMenu() }
    }

    Timer {
        id: commandDelay
        interval: Theme.contentTransitionDuration
        onTriggered: {
            if (root.pendingCommand.length > 0)
                Quickshell.execDetached(root.pendingCommand)

            root.pendingCommand = []
        }
    }
}
