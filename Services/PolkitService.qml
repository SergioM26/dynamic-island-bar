pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Polkit

Singleton {
    id: root

    signal authenticationStarted()
    signal authenticationEnded()

    readonly property bool registered: agent.isRegistered
    readonly property bool active: agent.isActive
    readonly property var flow: agent.flow
    property string hostMonitorName: ""

    function submit(response: string): void {
        if (root.flow?.isResponseRequired)
            root.flow.submit(response)
    }

    function cancel(): void {
        root.flow?.cancelAuthenticationRequest()
    }

    PolkitAgent {
        id: agent

        onAuthenticationRequestStarted: {
            root.hostMonitorName = Hyprland.focusedMonitor?.name ?? ""
            root.authenticationStarted()
        }

        onIsActiveChanged: {
            if (!isActive) {
                root.authenticationEnded()
                root.hostMonitorName = ""
            }
        }
    }
}
