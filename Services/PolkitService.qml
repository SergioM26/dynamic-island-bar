pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Polkit
import "../Config"

Singleton {
    id: root

    signal authenticationStarted()
    signal authenticationEnded()

    readonly property var agent: agentLoader.item
    readonly property bool active: root.agent?.isActive ?? false
    readonly property var flow: root.agent?.flow ?? null
    property string hostMonitorName: ""

    function submit(response: string): void {
        if (root.flow?.isResponseRequired)
            root.flow.submit(response)
    }

    function cancel(): void {
        root.flow?.cancelAuthenticationRequest()
    }

    LazyLoader {
        id: agentLoader
        active: Settings.enablePolkit

        PolkitAgent {
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
}
