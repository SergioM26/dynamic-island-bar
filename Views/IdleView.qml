// IdleView.qml
import QtQuick
import Quickshell.Services.UPower
import "../Components"

Item {
    // ========================================================================
    // Properties
    // ========================================================================
    id: idle
    readonly property int preferredWidth: hovered ? 300 : 120
    readonly property int preferredHeight: hovered ? 80 : 40
    property bool hovered: false

    implicitWidth: preferredWidth 
    implicitHeight: preferredHeight 

    property var battery: UPower.displayDevice

    // ========================================================================
    // Content
    // ========================================================================

    HoverHandler {
        onHoveredChanged: parent.hovered = hovered
        cursorShape: Qt.PointingHandCursor
    }

    // Border Battery Status
    Rectangle {
        id: border 
        anchors.fill: parent
        radius: Math.round(height / 2)
        color: "transparent"
        border.width: 2

        Behavior on border.color {
            ColorAnimation {
                duration: 300
            }
        }

        border.color: parent.battery.state === UPowerDeviceState.Charging ? "lime" : parent.battery.percentage <= 0.15 ? "red" : parent.battery.percentage <= 0.30 ? "yellow" : "black"    
    }

    // Idle and hovered
    Row {
        anchors.centerIn: parent

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

                Behavior on height {
                    NumberAnimation {
                        duration: 200
                    }
                }

                Behavior on opacity {
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
}
