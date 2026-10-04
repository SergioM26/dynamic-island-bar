import QtQuick
import "../Config"

Item {
    id: slider

    required property real value
    property bool muted: false
    property bool iconInteractive: false
    property url iconSource
    property url mutedIconSource: iconSource

    signal valueModified(real value)
    signal muteToggled()

    readonly property real normalizedValue: Math.max(0, Math.min(1, value))

    width: Theme.sliderWidth
    height: Theme.sliderIconHitSize

    ColorizedIcon {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.sliderIconSize
        height: Theme.sliderIconSize
        source: slider.muted ? slider.mutedIconSource : slider.iconSource
        color: Theme.foregroundColor

        MouseArea {
            anchors.centerIn: parent
            width: Theme.sliderIconHitSize
            height: Theme.sliderIconHitSize
            enabled: slider.iconInteractive
            onClicked: slider.muteToggled()
        }
    }

    Rectangle {
        id: track
        x: Theme.sliderIconSize + Theme.sliderSpacing
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, parent.width - x)
        height: Theme.sliderHeight
        radius: height / 2
        color: Theme.sliderTrackColor

        Item {
            id: progressClip
            anchors.left: parent.left
            width: parent.width * slider.normalizedValue
            height: parent.height
            clip: true
            opacity: slider.muted ? Theme.mutedSliderOpacity : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.contentTransitionDuration
                }
            }

            Rectangle {
                width: track.width
                height: track.height
                radius: track.radius
                color: Theme.sliderProgressColor
            }
        }

        MouseArea {
            anchors.fill: parent

            function updateValue(position: real): void {
                slider.valueModified(Math.max(0, Math.min(1, position / width)))
            }

            onPressed: mouse => updateValue(mouse.x)
            onPositionChanged: mouse => {
                if (pressed)
                    updateValue(mouse.x)
            }
        }
    }
}
