// Idle.qml
import QtQuick
import QtQuick.Effects
import Quickshell.Services.UPower
import "../Components"

Item {
    id: idle
    // required property var modelData
    property bool hovered: false
    y : 5

    // Animations
    Behavior on implicitWidth {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutCubic
        }
    }
    Behavior on implicitHeight{
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutCubic
        }
    }

    // Change size if it's hovered
    implicitWidth: hovered ? 300 : 120 
    implicitHeight: hovered ? 80 : 40 
    property var battery: UPower.displayDevice
    // Form
        MultiEffect {
            anchors.fill: rect
            source: rect

            shadowEnabled: true
            shadowBlur: 0.8
            shadowOpacity: 0.8
            shadowVerticalOffset: 2
        }
    Rectangle {
        id : rect
        anchors.fill: parent
        radius: Math.round(height / 2)
        color: "black"
        // state: "NORMAL"
        border.width : 2
        // border.color: "white"
        Behavior on border.color {
            ColorAnimation {
                duration: 300
            }
        }
        
    border.color:
        parent.battery.state === UPowerDeviceState.Charging
            ? "lime"
            : parent.battery.percentage <= 0.15
              ? "red"
              : parent.battery.percentage <= 0.30
                ? "yellow"
                : "black"
        }

    HoverHandler {
        onHoveredChanged: parent.hovered = hovered
        cursorShape: Qt.PointingHandCursor
    }

    // Content
    Row {
        anchors.centerIn: parent
        // spacing: 8
        Column {
            ClockWidget {
                id: clock
                anchors.horizontalCenter: parent.horizontalCenter
                fontSize: idle.hovered ? 20 : 16
                fontColor: "white"
            }

            Item {
                width: date.implicitWidth
                height: idle.hovered ? date.implicitHeight : 0

                opacity: idle.hovered ? 1 : 0

                Behavior on height{
                    NumberAnimation {
                        duration: 200
                    }
                }
                
                Behavior on opacity{
                    NumberAnimation {
                        duration: 200
                    }
                }

                DateWidget {
                    id: date
                    anchors.horizontalCenter: parent.horizontalCenter
                    fontSize: 14
                    fontColor: "white"
                }
            }
        }
    }
    // }
}
