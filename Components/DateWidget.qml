// DateWidget.qml
import QtQuick
import "../Services"
import "../Config"

Text {
    readonly property string date: TimeService.date
    required property real fontSize
    required property color fontColor

    font.pixelSize : fontSize
    font.family : Theme.fontFamily
    color: fontColor 
    text : date
}
