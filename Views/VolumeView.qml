import QtQuick
import "../Components"

Item {
    id: volume

    readonly property int preferredWidth: 200
    readonly property int preferredHeight: 40

    VolumeSlider {
        anchors.centerIn: parent
    }
}
