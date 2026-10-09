import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import "Views"
import "Controllers"
import "Config"
import "Services"

Variants {
    model: Quickshell.screens

    Component {
        PanelWindow {
            id: island
            required property var modelData

            screen: modelData
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: modelData.height
            exclusiveZone: Theme.exclusiveZone
            WlrLayershell.layer: FocusService.resettingSurface
                && modelData.name === FocusService.hostMonitorName
                ? WlrLayer.Bottom
                : PolkitService.active || PowerMenuService.visible
                || PowerProfileMenuService.visible || AppLauncherService.visible
                || ClipboardService.visible
                ? WlrLayer.Overlay
                : WlrLayer.Top
            WlrLayershell.keyboardFocus: controller.inputActive
                ? WlrKeyboardFocus.Exclusive
                : WlrKeyboardFocus.None

            mask: Region {
                item: PolkitService.active || PowerMenuService.visible
                    || PowerProfileMenuService.visible || AppLauncherService.visible
                    || ClipboardService.visible
                    ? modalScrim
                    : surface
            }

            Rectangle {
                id: modalScrim
                anchors.fill: parent
                z: 0
                color: Theme.modalScrimColor
                visible: opacity > 0
                opacity: PolkitService.active || PowerMenuService.visible
                    || PowerProfileMenuService.visible || AppLauncherService.visible
                    || ClipboardService.visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.detailTransitionDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }

            IslandController {
                id: controller
                authenticationHost: PolkitService.hostMonitorName.length > 0
                    ? modelData.name === PolkitService.hostMonitorName
                    : modelData === Quickshell.screens[0]
                sessionHost: PowerMenuService.hostMonitorName.length > 0
                    ? modelData.name === PowerMenuService.hostMonitorName
                    : modelData === Quickshell.screens[0]
                brightnessHost: modelData.name === BrightnessService.activeMonitorName
                workspaceHost: modelData.name === WorkspaceService.monitorName
                powerProfileHost: PowerProfileMenuService.hostMonitorName.length > 0
                    ? modelData.name === PowerProfileMenuService.hostMonitorName
                    : modelData === Quickshell.screens[0]
                launcherHost: AppLauncherService.hostMonitorName.length > 0
                    ? modelData.name === AppLauncherService.hostMonitorName
                    : modelData === Quickshell.screens[0]
                clipboardHost: ClipboardService.hostMonitorName.length > 0
                    ? modelData.name === ClipboardService.hostMonitorName
                    : modelData === Quickshell.screens[0]
            }

            Component {
                id: idleView
                IdleView {}
            }

            Component {
                id: volumeView
                VolumeView {}
            }

            Component {
                id: brightnessView
                BrightnessView {}
            }

            Component {
                id: workspaceView
                WorkspaceView {}
            }

            Component {
                id: authenticationView
                AuthenticationView {}
            }

            Component {
                id: sessionView
                SessionView {}
            }

            Component {
                id: powerProfileView
                PowerProfileView {}
            }

            Component {
                id: appLauncherView
                AppLauncherView { host: controller.launcherHost }
            }

            Component {
                id: clipboardView
                ClipboardView { host: controller.clipboardHost }
            }

            IslandSurface {
                id: surface
                z: 1
                controller: controller
                idleComponent: idleView
                volumeComponent: volumeView
                brightnessComponent: brightnessView
                workspaceComponent: workspaceView
                authenticationComponent: authenticationView
                sessionComponent: sessionView
                powerProfileComponent: powerProfileView
                appLauncherComponent: appLauncherView
                clipboardComponent: clipboardView
            }
        }
    }
}
