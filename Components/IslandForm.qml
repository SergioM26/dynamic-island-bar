import QtQuick
import QtQuick.Effects
import "../Config"

Item {
    id: islandForm

    property color borderColor: Theme.batteryNormalColor

    Rectangle {
        id: background
        anchors.fill: parent
        radius: height / 2
        color: Theme.backgroundColor
        border.width: Theme.borderWidth
        border.color: islandForm.borderColor

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.colorTransitionDuration
            }
        }
    }

    MultiEffect {
        anchors.fill: background
        source: background
        shadowEnabled: true
        shadowBlur: Theme.shadowBlur
        shadowOpacity: Theme.shadowOpacity
        shadowVerticalOffset: Theme.shadowVerticalOffset
    }
}
