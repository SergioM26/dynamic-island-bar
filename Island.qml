// Island.qml
import Quickshell
import QtQuick
import "Views"
import "Components"
import "Controllers"
import QtQuick.Effects

Variants {
    model: Quickshell.screens

    Component {
        PanelWindow {
            // ================================================================
            // Properties
            // ================================================================

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

            mask: Region {
                item: form 
            }

            exclusiveZone: 40

            // ================================================================
            // Effects
            // ================================================================

            // MultiEffect {
            //     anchors.fill: form 
            //     source: form 
            //
            //     shadowEnabled: true
            //     shadowBlur: 0.8
            //     shadowOpacity: 0.8
            //     shadowVerticalOffset: 2
            // }

            // ================================================================
            // Content
            // ================================================================

            property int targetWidth: content.item?.preferredWidth ?? 120
            property int targetHeight: content.item?.preferredHeight ?? 40 

            IslandForm {
                id : form
                targetWidth : island.targetWidth
                targetHeight : island.targetHeight
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
                VolumeView{}
            }

            Loader {
                id: content
                anchors.fill: form 
                sourceComponent: 
                controller.currentView === controller.volumeView ? volumeView :
                controller.currentView === controller.idleView ? idleView :
                idleView
            }
        }
    }
}
