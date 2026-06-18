// Island.qml
import Quickshell
import QtQuick
import "Views"
import "Services"
import "Components"
import QtQuick.Effects
import Quickshell.Hyprland

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

            MultiEffect {
                anchors.fill: form 
                source: form 

                shadowEnabled: true
                shadowBlur: 0.8
                shadowOpacity: 0.8
                shadowVerticalOffset: 2
            }

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

            Component {
                id: idleView
                IdleView {}
            }

            Component {
                id: volumeView
                VolumeView{}
            }

            Connections {
                target: Volumed

                function onVolumeUpdated() {
                    Stated.currentView =  Stated.volume
                    hideTimer.restart()
                }
            }
            Loader {
                id: content
                anchors.fill: form 
                sourceComponent: 
                Stated.currentView === Stated.volume ? volumeView :
                Stated.currentView === Stated.idle ? idleView :
                idleView
                // sourceComponent: island.volumeActive ? volumeView : idleView
                // sourceComponent: volumeView
            }

            // property bool volumeActive: false
            //
            Timer {
                id: hideTimer
                interval: 2000  // 2 segundos y regresa al idle
                onTriggered: Stated.currentView = Stated.idle 
            }

            // Connections {
            //     target: Volumed.defaultSink?.audio ?? null
            //     function onVolumeChanged() {
            //         // if (!island.shegcc) return  // ignora cambios tempranos
            //         island.volumeActive = true;
            //         hideTimer.restart();
            //     }
            // }
            // Loader {
            //     id: viewLoader
            //     anchors.horizontalCenter: parent.horizontalCenter
            //     anchors.top: parent.top
            //     sourceComponent: idleView
            //     // sourceComponent: island.volumeActive ? volumeView : idleView
            //     // sourceComponent: volumeView
            // }
        }
    }
}
