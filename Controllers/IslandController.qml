import QtQuick
import "../Services"

Item {
    id: controller

    readonly property int idleView: 0
    readonly property int volumeView: 1
    property int currentView: idleView

    Connections {
        target: Volumed

        function onVolumeUpdated() {
            controller.currentView = controller.volumeView
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: controller.currentView = controller.idleView
    }
}
