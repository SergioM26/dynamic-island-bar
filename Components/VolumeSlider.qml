import QtQuick
import "../Services"

Rectangle {
    id: slider

    property real normalizedVolume: Math.max(0, Math.min(1, Volumed.volume))

    height: 15
    radius: height / 2
    color: "gray"

    Behavior on width {
        NumberAnimation {
            duration: 320
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 320
            easing.type: Easing.InOutQuad
        }
    }

    width: 0
    opacity: 0

    Component.onCompleted: {
        width = 150
        opacity = 1
    }

    Rectangle {
        anchors.left: parent.left
        width: parent.width * slider.normalizedVolume
        height: parent.height
        radius: height / 2
        color: "white"

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
                Volumed.setVolume(mouse.x / width)
        }
    }
}
