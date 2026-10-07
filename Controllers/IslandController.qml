import QtQuick
import "../Services"
import "../Config"

Item {
    id: controller

    required property bool authenticationHost
    property bool sessionHost: false

    enum View {
        Idle,
        Volume,
        Brightness,
        Authentication,
        SessionMenu
    }

    property int currentView: IslandController.Idle
    property bool expanded: false
    property bool baseContentVisible: true
    property bool authenticationContentVisible: false
    property bool authenticationEngaged: false
    property bool sessionContentVisible: false
    property bool sessionEngaged: false
    readonly property bool authenticationActive:
        authenticationEngaged
    readonly property bool sessionActive: sessionEngaged
    readonly property bool inputActive: authenticationActive || sessionActive

    readonly property size targetSize:
        currentView === IslandController.Authentication
            ? Qt.size(Theme.authenticationWidth, Theme.authenticationHeight)
            : currentView === IslandController.SessionMenu
                ? Qt.size(Theme.sessionWidth, Theme.sessionHeight)
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
            if (controller.inputActive)
                return

            controller.currentView = IslandController.Brightness
            hideTimer.restart()
        }
    }

    Connections {
        target: PolkitService

        function onAuthenticationStarted() {
            if (!controller.authenticationHost)
                return

            hideTimer.stop()
            if (controller.sessionEngaged)
                PowerMenuService.closeMenu()

            sessionEnterMorphTimer.stop()
            sessionEnterContentTimer.stop()
            sessionExitMorphTimer.stop()
            sessionExitIdleTimer.stop()
            controller.sessionContentVisible = false
            controller.sessionEngaged = false
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
                if (!controller.sessionHost)
                    return

                if (controller.authenticationActive) {
                    PowerMenuService.closeMenu()
                    return
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
        id: hideTimer
        interval: 2000
        onTriggered: {
            if (!PolkitService.active)
                controller.currentView = IslandController.Idle
        }
    }
}
