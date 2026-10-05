import QtQuick
import "../Services"
import "../Config"

Item {
    id: controller

    required property bool authenticationHost

    enum View {
        Idle,
        Volume,
        Brightness,
        Authentication
    }

    property int currentView: IslandController.Idle
    property bool expanded: false
    property bool baseContentVisible: true
    property bool authenticationContentVisible: false
    property bool authenticationEngaged: false
    readonly property bool authenticationActive:
        authenticationEngaged

    readonly property size targetSize:
        currentView === IslandController.Authentication
            ? Qt.size(Theme.authenticationWidth, Theme.authenticationHeight)
            : currentView === IslandController.Volume || currentView === IslandController.Brightness
                ? Qt.size(Theme.controlWidth, Theme.controlHeight)
                : expanded
                    ? Qt.size(Theme.expandedWidth, Theme.expandedHeight)
                    : Qt.size(Theme.idleWidth, Theme.idleHeight)

    Connections {
        target: VolumeService

        function onAudioUpdated() {
            if (controller.authenticationActive)
                return

            controller.currentView = IslandController.Volume
            hideTimer.restart()
        }
    }

    Connections {
        target: BrightnessService

        function onBrightnessUpdated() {
            if (controller.authenticationActive)
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

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: {
            if (!PolkitService.active)
                controller.currentView = IslandController.Idle
        }
    }
}
