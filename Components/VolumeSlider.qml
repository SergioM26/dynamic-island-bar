import QtQuick
import "../Services"
import "../Config"

Rectangle {
    id: slider

    readonly property real normalizedVolume: Math.max(0, Math.min(1, VolumeService.volume))

    height: Theme.volumeSliderHeight
    radius: height / 2
    color: Theme.sliderTrackColor

    Behavior on width {
        NumberAnimation {
            duration: Theme.morphDuration
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.morphDuration
            easing.type: Easing.InOutQuad
        }
    }

    width: 0
    opacity: 0

    Component.onCompleted: {
        width = Theme.volumeSliderWidth
        opacity = 1
    }

    Rectangle {
        anchors.left: parent.left
        width: parent.width * slider.normalizedVolume
        height: parent.height
        radius: height / 2
        color: Theme.foregroundColor

        Text {
            x: 5
            anchors.verticalCenter: parent.verticalCenter
            text: ""
        }
    }

    MouseArea {
        anchors.fill: parent

        onPositionChanged: {
            if (pressed && mouse.x < width)
                VolumeService.setVolume(mouse.x / width)
        }
    }
}
