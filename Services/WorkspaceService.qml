pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Scope {
    id: root

    property string label: ""
    property string monitorName: ""
    property bool initialized: false

    signal workspaceActivated()

    function updateWorkspace(notify: bool): void {
        const workspace = Hyprland.focusedWorkspace
        if (!workspace)
            return

        root.label = workspace.id > 0
            ? workspace.id.toString()
            : workspace.name.replace(/^special:/, "")
        root.monitorName = workspace.monitor?.name
            ?? Hyprland.focusedMonitor?.name
            ?? ""

        if (notify)
            root.workspaceActivated()
    }

    Component.onCompleted: {
        updateWorkspace(false)
        initialized = true
    }

    Connections {
        target: Hyprland

        function onFocusedWorkspaceChanged() {
            root.updateWorkspace(root.initialized)
        }
    }
}
