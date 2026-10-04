import QtQuick
import QtQuick.Effects

Item {
    id: islandForm
    required property real targetWidth
    required property real targetHeight

    implicitWidth: targetWidth
    implicitHeight: targetHeight

    Rectangle {
        id: fondo
        // visible:false
        // opacity: 0
        anchors.fill : parent
        radius: Math.round(height / 2)

        color: "black" 
    }
    MultiEffect {
        anchors.fill : fondo 
        source : fondo 
        // autoPaddingEnabled: true
        // paddingRect: Qt.rect(20,10,10,10)
        shadowEnabled: true
        shadowBlur: 0.8
        shadowOpacity: 0.8
        shadowVerticalOffset: 2
    }
    // MultiEffect {
    //     anchors.fill: parent 
    //     source: parent 
    //     shadowEnabled: true
    //     shadowBlur: 0.8
    //     shadowOpacity: 0.8
    //     shadowVerticalOffset: 2
    // }
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


    // radius: Math.round(height / 2)
    // color: "black"
    // border.width : 2
}
