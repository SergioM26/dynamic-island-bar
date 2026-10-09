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
    property bool launcherHost: false
    property bool clipboardHost: false

    enum View {
        Idle,
        Volume,
        Brightness,
        Workspace,
        Authentication,
        SessionMenu,
        PowerProfiles,
        AppLauncher,
        ClipboardHistory
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
    property bool launcherContentVisible: false
    property bool launcherEngaged: false
    property bool clipboardContentVisible: false
    property bool clipboardEngaged: false
    property bool transientInteractionActive: false
    readonly property bool authenticationActive:
        authenticationEngaged
    readonly property bool sessionActive: sessionEngaged
    readonly property bool powerProfileActive: powerProfileEngaged
    readonly property bool launcherActive: launcherEngaged
    readonly property bool clipboardActive: clipboardEngaged
    readonly property bool inputActive:
        authenticationActive || sessionActive || powerProfileActive || launcherActive
            || clipboardActive
    readonly property bool largePanelActive:
        authenticationActive || launcherActive || clipboardActive
    readonly property real launcherTargetHeight:
        Theme.launcherHeaderHeight
        + Math.max(1, Math.min(AppLauncherService.resultCount, Theme.launcherMaximumRows))
            * Theme.launcherRowHeight
        + Theme.launcherListTopPadding
        + Theme.launcherBottomPadding
    readonly property real clipboardTargetHeight:
        Theme.launcherHeaderHeight
        + Math.max(1, Math.min(ClipboardService.resultCount, Theme.launcherMaximumRows))
            * Theme.launcherRowHeight
        + Theme.launcherListTopPadding
        + Theme.launcherBottomPadding

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
            : currentView === IslandController.AppLauncher
                ? Qt.size(Theme.launcherWidth, controller.launcherTargetHeight)
            : currentView === IslandController.ClipboardHistory
                ? Qt.size(Theme.launcherWidth, controller.clipboardTargetHeight)
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
            if (controller.authenticationHost)
                FocusService.capture()

            if (PowerMenuService.visible)
                PowerMenuService.closeMenu()
            if (PowerProfileMenuService.visible)
                PowerProfileMenuService.closeMenu()
            if (AppLauncherService.visible)
                AppLauncherService.close()
            if (ClipboardService.visible)
                ClipboardService.close()

            if (controller.authenticationHost)
                FocusService.hold()

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
            launcherEnterMorphTimer.stop()
            launcherEnterContentTimer.stop()
            launcherExitMorphTimer.stop()
            launcherExitIdleTimer.stop()
            controller.launcherContentVisible = false
            controller.launcherEngaged = false
            clipboardEnterMorphTimer.stop()
            clipboardEnterContentTimer.stop()
            clipboardExitMorphTimer.stop()
            clipboardExitIdleTimer.stop()
            controller.clipboardContentVisible = false
            controller.clipboardEngaged = false
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

            FocusService.restoreDelayed()
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
                if (AppLauncherService.visible)
                    AppLauncherService.close()
                if (ClipboardService.visible)
                    ClipboardService.close()

                if (!controller.sessionHost)
                    return

                if (PolkitService.active) {
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

                if (controller.launcherActive) {
                    launcherEnterMorphTimer.stop()
                    launcherEnterContentTimer.stop()
                    launcherExitMorphTimer.stop()
                    launcherExitIdleTimer.stop()
                    controller.launcherContentVisible = false
                    controller.launcherEngaged = false
                }

                if (controller.clipboardActive) {
                    clipboardEnterMorphTimer.stop()
                    clipboardEnterContentTimer.stop()
                    clipboardExitMorphTimer.stop()
                    clipboardExitIdleTimer.stop()
                    controller.clipboardContentVisible = false
                    controller.clipboardEngaged = false
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
                if (AppLauncherService.visible)
                    AppLauncherService.close()
                if (ClipboardService.visible)
                    ClipboardService.close()

                if (!controller.powerProfileHost)
                    return

                if (PolkitService.active) {
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

                if (controller.launcherActive) {
                    launcherEnterMorphTimer.stop()
                    launcherEnterContentTimer.stop()
                    launcherExitMorphTimer.stop()
                    launcherExitIdleTimer.stop()
                    controller.launcherContentVisible = false
                    controller.launcherEngaged = false
                }

                if (controller.clipboardActive) {
                    clipboardEnterMorphTimer.stop()
                    clipboardEnterContentTimer.stop()
                    clipboardExitMorphTimer.stop()
                    clipboardExitIdleTimer.stop()
                    controller.clipboardContentVisible = false
                    controller.clipboardEngaged = false
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

    Connections {
        target: AppLauncherService

        function onVisibleChanged() {
            if (AppLauncherService.visible) {
                if (PowerMenuService.visible)
                    PowerMenuService.closeMenu()
                if (PowerProfileMenuService.visible)
                    PowerProfileMenuService.closeMenu()
                if (ClipboardService.visible)
                    ClipboardService.close()

                if (!controller.launcherHost)
                    return

                if (PolkitService.active) {
                    AppLauncherService.close()
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

                if (controller.powerProfileActive) {
                    powerProfileEnterMorphTimer.stop()
                    powerProfileEnterContentTimer.stop()
                    powerProfileExitMorphTimer.stop()
                    powerProfileExitIdleTimer.stop()
                    controller.powerProfileContentVisible = false
                    controller.powerProfileEngaged = false
                }

                if (controller.clipboardActive) {
                    clipboardEnterMorphTimer.stop()
                    clipboardEnterContentTimer.stop()
                    clipboardExitMorphTimer.stop()
                    clipboardExitIdleTimer.stop()
                    controller.clipboardContentVisible = false
                    controller.clipboardEngaged = false
                }

                hideTimer.stop()
                launcherExitMorphTimer.stop()
                launcherExitIdleTimer.stop()
                controller.launcherEngaged = true
                controller.launcherContentVisible = false
                controller.baseContentVisible = false
                launcherEnterMorphTimer.restart()
                return
            }

            if (!controller.launcherEngaged)
                return

            launcherEnterMorphTimer.stop()
            launcherEnterContentTimer.stop()
            controller.launcherContentVisible = false

            if (controller.currentView === IslandController.AppLauncher)
                launcherExitMorphTimer.restart()
            else {
                controller.currentView = IslandController.Idle
                controller.launcherEngaged = false
                controller.baseContentVisible = true
            }
        }
    }

    Connections {
        target: ClipboardService

        function onVisibleChanged() {
            if (ClipboardService.visible) {
                if (PowerMenuService.visible)
                    PowerMenuService.closeMenu()
                if (PowerProfileMenuService.visible)
                    PowerProfileMenuService.closeMenu()
                if (AppLauncherService.visible)
                    AppLauncherService.close()

                if (!controller.clipboardHost)
                    return

                if (PolkitService.active) {
                    ClipboardService.close()
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

                if (controller.powerProfileActive) {
                    powerProfileEnterMorphTimer.stop()
                    powerProfileEnterContentTimer.stop()
                    powerProfileExitMorphTimer.stop()
                    powerProfileExitIdleTimer.stop()
                    controller.powerProfileContentVisible = false
                    controller.powerProfileEngaged = false
                }

                if (controller.launcherActive) {
                    launcherEnterMorphTimer.stop()
                    launcherEnterContentTimer.stop()
                    launcherExitMorphTimer.stop()
                    launcherExitIdleTimer.stop()
                    controller.launcherContentVisible = false
                    controller.launcherEngaged = false
                }

                hideTimer.stop()
                clipboardExitMorphTimer.stop()
                clipboardExitIdleTimer.stop()
                controller.clipboardEngaged = true
                controller.clipboardContentVisible = false
                controller.baseContentVisible = false
                clipboardEnterMorphTimer.restart()
                return
            }

            if (!controller.clipboardEngaged)
                return

            clipboardEnterMorphTimer.stop()
            clipboardEnterContentTimer.stop()
            controller.clipboardContentVisible = false

            if (controller.currentView === IslandController.ClipboardHistory)
                clipboardExitMorphTimer.restart()
            else {
                controller.currentView = IslandController.Idle
                controller.clipboardEngaged = false
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
        id: launcherEnterMorphTimer
        interval: Theme.contentTransitionDuration
        onTriggered: {
            if (!AppLauncherService.visible)
                return

            controller.currentView = IslandController.AppLauncher
            launcherEnterContentTimer.restart()
        }
    }

    Timer {
        id: launcherEnterContentTimer
        interval: Theme.morphDuration
        onTriggered: {
            if (AppLauncherService.visible)
                controller.launcherContentVisible = true
        }
    }

    Timer {
        id: launcherExitMorphTimer
        interval: Theme.contentTransitionDuration
        onTriggered: {
            controller.currentView = IslandController.Idle
            launcherExitIdleTimer.restart()
        }
    }

    Timer {
        id: launcherExitIdleTimer
        interval: Theme.morphDuration
        onTriggered: {
            controller.launcherEngaged = false
            controller.baseContentVisible = true
        }
    }

    Timer {
        id: clipboardEnterMorphTimer
        interval: Theme.contentTransitionDuration
        onTriggered: {
            if (!ClipboardService.visible)
                return

            controller.currentView = IslandController.ClipboardHistory
            clipboardEnterContentTimer.restart()
        }
    }

    Timer {
        id: clipboardEnterContentTimer
        interval: Theme.morphDuration
        onTriggered: {
            if (ClipboardService.visible)
                controller.clipboardContentVisible = true
        }
    }

    Timer {
        id: clipboardExitMorphTimer
        interval: Theme.contentTransitionDuration
        onTriggered: {
            controller.currentView = IslandController.Idle
            clipboardExitIdleTimer.restart()
        }
    }

    Timer {
        id: clipboardExitIdleTimer
        interval: Theme.morphDuration
        onTriggered: {
            controller.clipboardEngaged = false
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
