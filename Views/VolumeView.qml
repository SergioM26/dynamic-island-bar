import QtQuick
import "../Controls"

Item {
    id: volume

    readonly property bool interacting: control.interacting

    VolumeControl {
        id: control
        anchors.centerIn: parent
    }
}
