import QtQuick
import QtQuick.Effects

Item {
    id: root

    required property url source
    property color color: "white"

    Image {
        anchors.fill: parent
        source: root.source
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
        layer.enabled: true
        layer.effect: MultiEffect {
            brightness: 1
            colorization: 1
            colorizationColor: root.color
        }
    }
}
