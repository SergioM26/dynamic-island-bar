import QtQuick
import "../Services"
import "../Config"

Item {
    id: controller

    enum View {
        Idle,
        Volume,
        Brightness
    }

    property int currentView: IslandController.Idle
    property bool expanded: false

    readonly property size targetSize:
        currentView === IslandController.Volume || currentView === IslandController.Brightness
        ? Qt.size(Theme.controlWidth, Theme.controlHeight)
        : expanded
            ? Qt.size(Theme.expandedWidth, Theme.expandedHeight)
            : Qt.size(Theme.idleWidth, Theme.idleHeight)

    Connections {
        target: VolumeService

        function onAudioUpdated() {
            controller.currentView = IslandController.Volume
            hideTimer.restart()
        }
    }

    Connections {
        target: BrightnessService

        function onBrightnessUpdated() {
            controller.currentView = IslandController.Brightness
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: controller.currentView = IslandController.Idle
    }
}
