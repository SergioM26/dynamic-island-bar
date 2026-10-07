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
            WlrLayershell.layer: PolkitService.active || PowerMenuService.visible
                ? WlrLayer.Overlay
                : WlrLayer.Top
            WlrLayershell.keyboardFocus: controller.inputActive
                ? WlrKeyboardFocus.Exclusive
                : WlrKeyboardFocus.None

            mask: Region {
                item: PolkitService.active || PowerMenuService.visible
                    ? modalScrim
                    : surface
            }

            Rectangle {
                id: modalScrim
                anchors.fill: parent
                z: 0
                color: Theme.modalScrimColor
                visible: opacity > 0
                opacity: PolkitService.active || PowerMenuService.visible ? 1 : 0

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
                id: authenticationView
                AuthenticationView {}
            }

            Component {
                id: sessionView
                SessionView {}
            }

            IslandSurface {
                id: surface
                z: 1
                controller: controller
                idleComponent: idleView
                volumeComponent: volumeView
                brightnessComponent: brightnessView
                authenticationComponent: authenticationView
                sessionComponent: sessionView
            }
        }
    }
}
