// ClockWidget.qml
import QtQuick
import "../Services"
import "../Config"

Text {
    readonly property string time: TimeService.time
    required property real fontSize
    required property color fontColor
    Behavior on font.pixelSize{
        NumberAnimation {
            duration: Theme.morphDuration
            easing.type: Easing.OutCubic
        }
    }

    font.pixelSize : fontSize
    font.family : Theme.fontFamily
    color: fontColor 
    text : time 
}
