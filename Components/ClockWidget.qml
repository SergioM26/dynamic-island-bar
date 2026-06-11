// ClockWidget.qml
import QtQuick
import "../Services"

Text {
	property string time: Time.time
    required property double fontSize
    required property string fontColor

    font.pixelSize : fontSize
    font.family : "monospace"
    color: fontColor 
    text : time 
}
