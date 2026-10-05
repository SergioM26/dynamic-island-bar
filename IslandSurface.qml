import QtQuick
import Quickshell.Services.UPower
import "Components"
import "Controllers"
import "Config"

Item {
    id: surface

    required property IslandController controller
    required property Component idleComponent
    required property Component volumeComponent
    required property Component brightnessComponent
    required property Component authenticationComponent

    width: controller.targetSize.width
    height: controller.targetSize.height
    anchors.horizontalCenter: parent.horizontalCenter
    y: Theme.islandTopMargin

    readonly property var battery: UPower.displayDevice
    readonly property color batteryColor:
        battery.state === UPowerDeviceState.Charging ? Theme.batteryChargingColor :
        battery.percentage <= 0.15 ? Theme.batteryLowColor :
        battery.percentage <= 0.30 ? Theme.batteryWarningColor : Theme.batteryNormalColor

    Behavior on width {
        NumberAnimation {
            duration: Theme.morphDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: Theme.morphDuration
            easing.type: Easing.OutCubic
        }
    }

    IslandForm {
        anchors.fill: parent
        borderColor: surface.batteryColor
        borderWidth: surface.controller.authenticationActive ? 0 : Theme.borderWidth
        // Follow the animated height directly. Animating radius separately made
        // the island briefly look rectangular during the idle hover morph.
        cornerRadius: surface.controller.authenticationActive
            ? Math.min(Theme.authenticationRadius, height / 2)
            : height / 2
    }

    Loader {
        id: idleLoader
        anchors.fill: parent
        sourceComponent: surface.idleComponent
        visible: opacity > 0
        opacity: surface.controller.baseContentVisible
            && surface.controller.currentView === IslandController.Idle ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.contentTransitionDuration }
        }
    }

    Binding {
        target: idleLoader.item
        property: "expanded"
        value: surface.controller.expanded
        when: idleLoader.status === Loader.Ready
    }

    Loader {
        id: volumeLoader
        anchors.fill: parent
        clip: true
        sourceComponent: surface.volumeComponent
        visible: opacity > 0
        opacity: surface.controller.baseContentVisible
            && surface.controller.currentView === IslandController.Volume ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.contentTransitionDuration }
        }
    }

    Loader {
        id: brightnessLoader
        anchors.fill: parent
        clip: true
        sourceComponent: surface.brightnessComponent
        visible: opacity > 0
        opacity: surface.controller.baseContentVisible
            && surface.controller.currentView === IslandController.Brightness ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.contentTransitionDuration }
        }
    }

    Loader {
        id: authenticationLoader
        anchors.fill: parent
        clip: true
        sourceComponent: surface.authenticationComponent
        visible: opacity > 0
        opacity: surface.controller.authenticationContentVisible ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.contentTransitionDuration }
        }
    }

    HoverHandler {
        enabled: surface.controller.currentView === IslandController.Idle
            && !surface.controller.authenticationActive
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: surface.controller.expanded = hovered
    }

    Connections {
        target: surface.controller

        function onCurrentViewChanged() {
            if (surface.controller.currentView !== IslandController.Idle)
                surface.controller.expanded = false
        }
    }
}
