import QtQuick
import "../Config"
import "../Services"
import "../Components"

Item {
    width: Theme.systemControlWidth
    height: Theme.sliderIconHitSize

    SystemSlider {
        id: slider
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        value: VolumeService.volume / VolumeService.maximumVolume
        muted: VolumeService.muted
        iconInteractive: true
        iconSource: VolumeService.volume <= 0
            ? Qt.resolvedUrl("../Assets/Icons/lucide/volume.svg")
            : VolumeService.volume < 0.5
                ? Qt.resolvedUrl("../Assets/Icons/lucide/volume-1.svg")
                : Qt.resolvedUrl("../Assets/Icons/lucide/volume-2.svg")
        mutedIconSource: Qt.resolvedUrl("../Assets/Icons/lucide/volume-x.svg")

        onValueModified: value => {
            if (VolumeService.muted)
                VolumeService.setMuted(false)

            VolumeService.setVolume(value * VolumeService.maximumVolume)
        }

        onMuteToggled: VolumeService.toggleMuted()
    }

    Text {
        anchors.left: slider.right
        anchors.leftMargin: Theme.sliderValueSpacing
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.sliderValueWidth

        text: Math.round(VolumeService.volume * 100) + "%"
        color: Theme.foregroundColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.sliderValueFontSize
        horizontalAlignment: Text.AlignRight
    }
}
