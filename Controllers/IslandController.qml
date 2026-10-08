import QtQuick
import "../Services"
import "../Config"

Item {
    id: controller

    required property bool authenticationHost
    property bool sessionHost: false
    property bool brightnessHost: false
    property bool workspaceHost: false
    property bool powerProfileHost: false

    enum View {
        Idle,
        Volume,
        Brightness,
        Workspace,
        Authentication,
        SessionMenu,
        PowerProfiles
    }

    property int currentView: IslandController.Idle
    property bool expanded: false
    property bool baseContentVisible: true
    property bool authenticationContentVisible: false
    property bool authenticationEngaged: false
    property bool sessionContentVisible: false
    property bool sessionEngaged: false
    property bool powerProfileContentVisible: false
    property bool powerProfileEngaged: false
    property bool transientInteractionActive: false
    readonly property bool authenticationActive:
        authenticationEngaged
    readonly property bool sessionActive: sessionEngaged
    readonly property bool powerProfileActive: powerProfileEngaged
    readonly property bool inputActive:
        authenticationActive || sessionActive || powerProfileActive

    onTransientInteractionActiveChanged: {
        if (transientInteractionActive) {
            hideTimer.stop()
        } else if (currentView === IslandController.Volume
                   || currentView === IslandController.Brightness) {
            hideTimer.restart()
        }
    }

    readonly property size targetSize:
        currentView === IslandController.SessionMenu && PowerMenuService.compact
            ? Qt.size(Theme.optionConfirmWidth, Theme.optionConfirmHeight)
            : currentView === IslandController.PowerProfiles && PowerProfileMenuService.compact
                ? Qt.size(Theme.optionConfirmWidth, Theme.optionConfirmHeight)
            : currentView === IslandController.Authentication
            ? Qt.size(Theme.authenticationWidth, Theme.authenticationHeight)
            : currentView === IslandController.SessionMenu
                ? Qt.size(Theme.sessionWidth, Theme.sessionHeight)
            : currentView === IslandController.PowerProfiles
                ? Qt.size(Theme.powerProfileWidth, Theme.powerProfileHeight)
            : currentView === IslandController.Workspace
                ? Qt.size(Theme.workspaceSize, Theme.workspaceSize)
            : currentView === IslandController.Volume || currentView === IslandController.Brightness
                ? Qt.size(Theme.controlWidth, Theme.controlHeight)
                : expanded
                    ? Qt.size(Theme.expandedWidth, Theme.expandedHeight)
                    : Qt.size(Theme.idleWidth, Theme.idleHeight)

    Connections {
        target: VolumeService

        function onAudioUpdated() {
            if (controller.inputActive)
                return

            controller.currentView = IslandController.Volume
            hideTimer.restart()
        }
    }

    Connections {
        target: BrightnessService

        function onBrightnessUpdated() {
            if (controller.inputActive || !controller.brightnessHost)
                return

            controller.currentView = IslandController.Brightness
            hideTimer.restart()
        }
    }

    Connections {
        target: WorkspaceService

        function onWorkspaceActivated() {
            if (controller.inputActive || !controller.workspaceHost)
                return

            controller.currentView = IslandController.Workspace
            hideTimer.restart()
        }
    }

    Connections {
        target: PolkitService

        function onAuthenticationStarted() {
            if (PowerMenuService.visible)
                PowerMenuService.closeMenu()
            if (PowerProfileMenuService.visible)
                PowerProfileMenuService.closeMenu()

            if (!controller.authenticationHost)
                return

            hideTimer.stop()
            sessionEnterMorphTimer.stop()
            sessionEnterContentTimer.stop()
            sessionExitMorphTimer.stop()
            sessionExitIdleTimer.stop()
            controller.sessionContentVisible = false
            controller.sessionEngaged = false
            powerProfileEnterMorphTimer.stop()
            powerProfileEnterContentTimer.stop()
            powerProfileExitMorphTimer.stop()
            powerProfileExitIdleTimer.stop()
            controller.powerProfileContentVisible = false
            controller.powerProfileEngaged = false
            authenticationExitMorphTimer.stop()
            authenticationExitIdleTimer.stop()
            controller.authenticationEngaged = true
            controller.authenticationContentVisible = false
            controller.baseContentVisible = false
            authenticationEnterMorphTimer.restart()
        }

        function onAuthenticationEnded() {
            if (!controller.authenticationEngaged)
                return

            authenticationEnterMorphTimer.stop()
            authenticationEnterContentTimer.stop()
            controller.authenticationContentVisible = false

            if (controller.currentView === IslandController.Authentication)
                authenticationExitMorphTimer.restart()
            else {
                controller.currentView = IslandController.Idle
                controller.authenticationEngaged = false
                controller.baseContentVisible = true
            }
        }
    }

    Connections {
        target: PowerMenuService

        function onVisibleChanged() {
            if (PowerMenuService.visible) {
                if (PowerProfileMenuService.visible)
                    PowerProfileMenuService.closeMenu()

                if (!controller.sessionHost)
                    return

                if (controller.authenticationActive) {
                    PowerMenuService.closeMenu()
                    return
                }

                if (controller.powerProfileActive) {
                    powerProfileEnterMorphTimer.stop()
                    powerProfileEnterContentTimer.stop()
                    powerProfileExitMorphTimer.stop()
                    powerProfileExitIdleTimer.stop()
                    controller.powerProfileContentVisible = false
                    controller.powerProfileEngaged = false
                }

                hideTimer.stop()
                sessionExitMorphTimer.stop()
                sessionExitIdleTimer.stop()
                controller.sessionEngaged = true
                controller.sessionContentVisible = false
                controller.baseContentVisible = false
                sessionEnterMorphTimer.restart()
                return
            }

            if (!controller.sessionEngaged)
                return

            sessionEnterMorphTimer.stop()
            sessionEnterContentTimer.stop()
            controller.sessionContentVisible = false

            if (controller.currentView === IslandController.SessionMenu)
                sessionExitMorphTimer.restart()
            else {
                controller.currentView = IslandController.Idle
                controller.sessionEngaged = false
                controller.baseContentVisible = true
            }
        }
    }

    Connections {
        target: PowerProfileMenuService

        function onVisibleChanged() {
            if (PowerProfileMenuService.visible) {
                if (PowerMenuService.visible)
                    PowerMenuService.closeMenu()

                if (!controller.powerProfileHost)
                    return

                if (controller.authenticationActive) {
                    PowerProfileMenuService.closeMenu()
                    return
                }

                if (controller.sessionActive) {
                    sessionEnterMorphTimer.stop()
                    sessionEnterContentTimer.stop()
                    sessionExitMorphTimer.stop()
                    sessionExitIdleTimer.stop()
                    controller.sessionContentVisible = false
                    controller.sessionEngaged = false
                }

                hideTimer.stop()
                powerProfileExitMorphTimer.stop()
                powerProfileExitIdleTimer.stop()
                controller.powerProfileEngaged = true
                controller.powerProfileContentVisible = false
                controller.baseContentVisible = false
                powerProfileEnterMorphTimer.restart()
                return
            }

            if (!controller.powerProfileEngaged)
                return

            powerProfileEnterMorphTimer.stop()
            powerProfileEnterContentTimer.stop()
            controller.powerProfileContentVisible = false

            if (controller.currentView === IslandController.PowerProfiles)
                powerProfileExitMorphTimer.restart()
            else {
                controller.currentView = IslandController.Idle
                controller.powerProfileEngaged = false
                controller.baseContentVisible = true
            }
        }
    }

    // Enter: fade current content, morph the empty island, then reveal Polkit.
    Timer {
        id: authenticationEnterMorphTimer
        interval: Theme.contentTransitionDuration
        onTriggered: {
            if (!PolkitService.active)
                return

            controller.currentView = IslandController.Authentication
            authenticationEnterContentTimer.restart()
        }
    }

    Timer {
        id: authenticationEnterContentTimer
        interval: Theme.morphDuration
        onTriggered: {
            if (PolkitService.active)
                controller.authenticationContentVisible = true
        }
    }

    // Exit performs the same three phases in reverse.
    Timer {
        id: authenticationExitMorphTimer
        interval: Theme.contentTransitionDuration
        onTriggered: {
            controller.currentView = IslandController.Idle
            authenticationExitIdleTimer.restart()
        }
    }

    Timer {
        id: authenticationExitIdleTimer
        interval: Theme.morphDuration
        onTriggered: {
            controller.authenticationEngaged = false
            controller.baseContentVisible = true
        }
    }

    // Session menu uses the same content → shape → content sequence.
    Timer {
        id: sessionEnterMorphTimer
        interval: Theme.contentTransitionDuration
        onTriggered: {
            if (!PowerMenuService.visible)
                return

            controller.currentView = IslandController.SessionMenu
            sessionEnterContentTimer.restart()
        }
    }

    Timer {
        id: sessionEnterContentTimer
        interval: Theme.morphDuration
        onTriggered: {
            if (PowerMenuService.visible)
                controller.sessionContentVisible = true
        }
    }

    Timer {
        id: sessionExitMorphTimer
        interval: Theme.contentTransitionDuration
        onTriggered: {
            controller.currentView = IslandController.Idle
            sessionExitIdleTimer.restart()
        }
    }

    Timer {
        id: sessionExitIdleTimer
        interval: Theme.morphDuration
        onTriggered: {
            controller.sessionEngaged = false
            controller.baseContentVisible = true
        }
    }

    Timer {
        id: powerProfileEnterMorphTimer
        interval: Theme.contentTransitionDuration
        onTriggered: {
            if (!PowerProfileMenuService.visible)
                return

            controller.currentView = IslandController.PowerProfiles
            powerProfileEnterContentTimer.restart()
        }
    }

    Timer {
        id: powerProfileEnterContentTimer
        interval: Theme.morphDuration
        onTriggered: {
            if (PowerProfileMenuService.visible)
                controller.powerProfileContentVisible = true
        }
    }

    Timer {
        id: powerProfileExitMorphTimer
        interval: Theme.contentTransitionDuration
        onTriggered: {
            controller.currentView = IslandController.Idle
            powerProfileExitIdleTimer.restart()
        }
    }

    Timer {
        id: powerProfileExitIdleTimer
        interval: Theme.morphDuration
        onTriggered: {
            controller.powerProfileEngaged = false
            controller.baseContentVisible = true
        }
    }

    Timer {
        id: hideTimer
        interval: controller.currentView === IslandController.Workspace ? 1200 : 2000
        onTriggered: {
            if (controller.transientInteractionActive)
                return

            if (!PolkitService.active)
                controller.currentView = IslandController.Idle
        }
    }
}
