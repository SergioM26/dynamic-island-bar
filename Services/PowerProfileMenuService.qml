pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.UPower
import "../Config"

Singleton {
    id: root

    property bool visible: false
    property bool confirming: false
    property bool compact: false
    property string hostMonitorName: ""
    property int pendingProfile: -1
    readonly property int profile: PowerProfiles.profile
    readonly property bool hasPerformanceProfile: PowerProfiles.hasPerformanceProfile

    function showMenu(): void {
        FocusService.capture()
        root.confirming = false
        root.compact = false
        root.hostMonitorName = Hyprland.focusedMonitor?.name ?? ""
        root.visible = true
        FocusService.hold()
    }

    function closeMenu(): void {
        root.confirming = false
        root.compact = false
        compactDelay.stop()
        root.visible = false
        FocusService.restoreDelayed()
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

    function activate(profile: int): void {
        if (profile === PowerProfile.Performance && !root.hasPerformanceProfile)
            return

        PowerProfiles.profile = profile
        root.closeMenu()
    }

    function commit(profile: int): void {
        if (profile === PowerProfile.Performance && !root.hasPerformanceProfile)
            return

        root.pendingProfile = profile
        root.visible = false
        FocusService.restoreDelayed()
        applyTimer.restart()
    }

    function activateByName(profile: string): void {
        switch (profile) {
        case "power-saver":
            root.activate(PowerProfile.PowerSaver)
            break
        case "balanced":
            root.activate(PowerProfile.Balanced)
            break
        case "performance":
            root.activate(PowerProfile.Performance)
            break
        }
    }

    IpcHandler {
        target: "powerProfiles"

        function toggle(): void { root.toggleMenu() }
        function open(): void { root.showMenu() }
        function close(): void { root.closeMenu() }
        function set(profile: string): void { root.activateByName(profile) }
        function get(): string { return PowerProfile.toString(root.profile) }
    }

    Timer {
        id: compactDelay
        interval: Theme.optionCenterDuration
        onTriggered: root.compact = root.confirming
    }

    Timer {
        id: applyTimer
        interval: Theme.contentTransitionDuration + Theme.morphDuration
        onTriggered: {
            if (root.pendingProfile >= 0)
                PowerProfiles.profile = root.pendingProfile

            root.pendingProfile = -1
            root.confirming = false
            root.compact = false
        }
    }
}
