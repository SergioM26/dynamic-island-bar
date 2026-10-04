// IdleView.qml
import QtQuick
import "../Components"
import "../Config"

Item {
    // ========================================================================
    // Properties
    // ========================================================================
    id: idle
    property bool expanded: false

    // ========================================================================
    // Content
    // ========================================================================

    // Idle and hovered
    Row {
        anchors.centerIn: parent

        Column {
            ClockWidget {
                id: clock
                anchors.horizontalCenter: parent.horizontalCenter
                fontSize: idle.expanded ? Theme.expandedClockFontSize : Theme.clockFontSize
                fontColor: Theme.foregroundColor
            }

            Item {
                width: date.implicitWidth
                height: idle.expanded ? date.implicitHeight : 0

                opacity: idle.expanded ? 1 : 0

                Behavior on height {
                    NumberAnimation {
                        duration: Theme.detailTransitionDuration
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.detailTransitionDuration
                    }
                }

                DateWidget {
                    id: date
                    anchors.horizontalCenter: parent.horizontalCenter
                    fontSize: Theme.dateFontSize
                    fontColor: Theme.foregroundColor
                }
            }
        }
    }
}
