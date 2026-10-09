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
    property int resultCount: 0
    property string terminalCommand: "ghostty"
    property var pendingEntry: null

    function show(): void {
        FocusService.capture()
        root.hostMonitorName = Hyprland.focusedMonitor?.name ?? ""
        root.visible = true
        FocusService.hold()
    }

    function close(): void {
        root.visible = false
        FocusService.restoreDelayed()
    }

    function toggle(): void {
        if (root.visible)
            root.close()
        else
            root.show()
    }

    function launch(entry: var): void {
        if (!entry)
            return

        root.pendingEntry = entry
        FocusService.forget()
        root.visible = false
        launchDelay.restart()
    }

    function executePending(): void {
        const entry = root.pendingEntry
        root.pendingEntry = null
        if (!entry)
            return

        if (entry.runInTerminal) {
            Quickshell.execDetached({
                command: [root.terminalCommand, "-e"].concat(entry.command),
                workingDirectory: entry.workingDirectory
            })
        } else {
            entry.execute()
        }
    }

    IpcHandler {
        target: "appLauncher"

        function toggle(): void { root.toggle() }
        function open(): void { root.show() }
        function close(): void { root.close() }
    }

    Timer {
        id: launchDelay
        interval: Theme.contentTransitionDuration + Theme.morphDuration
        onTriggered: root.executePending()
    }
}
