// DateWidget.qml
import QtQuick
import "../Services"

Text {
    property string date: Time.date
    required property double fontSize
    required property string fontColor

    font.pixelSize : fontSize
    font.family : "monospace"
    color: fontColor 
    text : date
}
