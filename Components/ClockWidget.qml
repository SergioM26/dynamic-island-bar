// ClockWidget.qml
import QtQuick
import "../Services"

Text {
	property string time: Timed.time
    required property double fontSize
    required property string fontColor
    Behavior on font.pixelSize{
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutCubic
        }
    }

    font.pixelSize : fontSize
    font.family : "monospace"
    color: fontColor 
    text : time 
}
