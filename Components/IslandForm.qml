import QtQuick

Rectangle {
    id: islandForm
    required property real targetWidth
    required property real targetHeight

    implicitWidth: targetWidth
    implicitHeight: targetHeight

    // Animations
    Behavior on implicitWidth {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutCubic
        }
    }
    Behavior on implicitHeight {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutCubic
        }
    }

    anchors.horizontalCenter: parent.horizontalCenter
    y: 5


    radius: Math.round(height / 2)
    color: "black"
    // border.width : 2
}
