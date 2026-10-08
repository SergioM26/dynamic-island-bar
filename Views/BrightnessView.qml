import QtQuick
import "../Controls"

Item {
    id: root

    readonly property bool interacting: control.interacting

    BrightnessControl {
        id: control
        anchors.centerIn: parent
    }
}
