import QtQuick
import "../Config"

Rectangle {
    id: button

    required property string label
    property bool primary: false
    signal clicked()

    implicitWidth: labelText.implicitWidth + Theme.buttonHorizontalPadding * 2
    implicitHeight: Theme.buttonHeight
    radius: Theme.buttonRadius
    color: primary
        ? Theme.foregroundColor
        : hovered.hovered ? Theme.buttonHoverColor : Theme.buttonColor
    border.width: 0

    Text {
        id: labelText
        anchors.centerIn: parent
        text: button.label
        color: button.primary ? Theme.backgroundColor : Theme.foregroundColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.buttonFontSize
    }

    HoverHandler {
        id: hovered
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: button.clicked()
    }
}
