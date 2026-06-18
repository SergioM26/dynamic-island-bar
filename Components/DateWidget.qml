// DateWidget.qml
import QtQuick
import "../Services"

Text {
    property string date: Timed.date
    required property double fontSize
    required property string fontColor

    font.pixelSize : fontSize
    font.family : "monospace"
    color: fontColor 
    text : date
}
