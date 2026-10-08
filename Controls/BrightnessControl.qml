import QtQuick
import "../Config"
import "../Services"
import "../Components"

Item {
    id: root

    readonly property bool interacting: slider.interacting

    width: Theme.systemControlWidth
    height: Theme.sliderIconHitSize

    SystemSlider {
        id: slider
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        value: BrightnessService.brightness
        iconSource: Qt.resolvedUrl("../Assets/Icons/lucide/sun.svg")

        onValueModified: value => BrightnessService.setBrightness(value)
    }

    Text {
        anchors.left: slider.right
        anchors.leftMargin: Theme.sliderValueSpacing
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.sliderValueWidth

        text: Math.round(BrightnessService.brightness * 100) + "%"
        color: Theme.foregroundColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.sliderValueFontSize
        horizontalAlignment: Text.AlignRight
    }
}
