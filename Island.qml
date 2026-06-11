import Quickshell
import QtQuick
import "Views"

Scope {
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
                    left : true
                    right : true
                }
                height : modelData.height
                mask: Region { item :viewLoader }
                exclusiveZone: 40

                // margins.top: 5
                
                Component {
                    id: idleView
                    Idle {
                        // modelData: island.modelData
                    }
                }

                Loader {
                    id: viewLoader
                    anchors.horizontalCenter : parent.horizontalCenter
                    anchors.top : parent.top
                    sourceComponent: idleView
                }

            }
        }
    }
}
