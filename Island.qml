import Quickshell
import QtQuick
import "Views"
import "Controllers"
import "Config"

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

            mask: Region {
                item: surface
            }

            IslandController {
                id: controller
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

            IslandSurface {
                id: surface
                controller: controller
                idleComponent: idleView
                volumeComponent: volumeView
                brightnessComponent: brightnessView
            }
        }
    }
}
