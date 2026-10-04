import QtQuick
import "../Services"
import "../Config"

Item {
    id: controller

    enum View {
        Idle,
        Volume
    }

    property int currentView: IslandController.Idle
    property bool expanded: false

    readonly property size targetSize: currentView === IslandController.Volume
        ? Qt.size(Theme.volumeWidth, Theme.volumeHeight)
        : expanded
            ? Qt.size(Theme.expandedWidth, Theme.expandedHeight)
            : Qt.size(Theme.idleWidth, Theme.idleHeight)

    Connections {
        target: VolumeService

        function onVolumeUpdated() {
            controller.currentView = IslandController.Volume
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: controller.currentView = IslandController.Idle
    }
}
