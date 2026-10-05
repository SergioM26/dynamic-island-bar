import QtQuick
import QtQuick.Effects
import "../Config"

Item {
    id: islandForm

    property color borderColor: Theme.batteryNormalColor
    property real borderWidth: Theme.borderWidth
    property real cornerRadius: height / 2

    Rectangle {
        id: background
        anchors.fill: parent
        radius: islandForm.cornerRadius
        color: Theme.backgroundColor
        border.width: islandForm.borderWidth
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
