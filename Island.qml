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
            WlrLayershell.layer: controller.authenticationActive
                ? WlrLayer.Overlay
                : WlrLayer.Top
            WlrLayershell.keyboardFocus: controller.authenticationActive
                ? WlrKeyboardFocus.Exclusive
                : WlrKeyboardFocus.None

            mask: Region {
                item: surface
            }

            IslandController {
                id: controller
                authenticationHost: PolkitService.hostMonitorName.length > 0
                    ? modelData.name === PolkitService.hostMonitorName
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

            IslandSurface {
                id: surface
                controller: controller
                idleComponent: idleView
                volumeComponent: volumeView
                brightnessComponent: brightnessView
                authenticationComponent: authenticationView
            }
        }
    }
}
