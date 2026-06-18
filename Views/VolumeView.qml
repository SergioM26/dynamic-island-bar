// VolumeView.qml
import QtQuick
// import QtQuick.Controls
import "../Services"

Item {
    id: volume

    readonly property int preferredWidth: 200
    readonly property int preferredHeight: 40

    Rectangle {
        anchors.centerIn : parent
        height : 15 
        radius : height / 2
        color : "gray"

        // Animation
        Behavior on width{
            NumberAnimation {
                duration: 320
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on opacity{
            NumberAnimation {
                duration: 320
                easing.type: Easing.InOutQuad
            }
        }

        width: 0
        opacity : 0

        Component.onCompleted:{
            width = 150 
            opacity = 1
        }


        Rectangle {
            id: rect
            anchors.left : parent.left

            width: parent.width * Volumed.volume
            height: parent.height
            radius : height / 2
            color: "white"

            Text {
                x : 5 
                // anchors.left : parent.left
                anchors.verticalCenter : parent.verticalCenter
                text : ""
            }
        }

        MouseArea {
            anchors.fill : parent
            // onClicked: (mouse)=> {
            //     // while(drag.active){
            //         Volumed.setVolume(mouse.x / width)
            //     // }
            // }
            onPositionChanged: {
                if(pressed && mouse.x < width){
                    Volumed.setVolume(mouse.x / width)
                }
            }
        }
    }
    
    // Slider {
    //     id: slider
    //     property real targetWidth : 120
    //     anchors.centerIn : parent
    //     background : Rectangle {
    //         color : "gray" 
    //         radius : height / 2
    //     }
    //
    //     // Animation
    //     Behavior on width{
    //         NumberAnimation {
    //             duration: 300
    //             // easing.type: Easing.InOutQuad
    //         }
    //     }
    //
    //     Behavior on opacity{
    //         NumberAnimation {
    //             duration: 300
    //             // easing.type: Easing.InOutQuad
    //         }
    //     }
    //
    //     width: 0
    //     opacity : 0
    //     Component.onCompleted:{
    //         width = 160 
    //         opacity = 1
    //     }
    //
    //     from : 1
    //     to: 100
    //     Binding on value {
    //         value : Math.round(Volumed.volume * 100)
    //         when : !slider.pressed 
    //     }
    //
    //
    //     onMoved: Volumed.setVolume(value / 100)
    //
    //     
    //     
    // }
}

