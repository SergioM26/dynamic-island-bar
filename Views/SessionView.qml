import QtQuick
import "../Components"
import "../Services"
import "../Config"

FocusScope {
    id: root

    property int selectedIndex: 0
    readonly property var actions: [
        {
            name: "Power off",
            action: "poweroff",
            iconSize: 27,
            icon: Qt.resolvedUrl("../Assets/Icons/lucide/power.svg")
        },
        {
            name: "Suspend",
            action: "suspend",
            iconSize: 26,
            icon: Qt.resolvedUrl("../Assets/Icons/lucide/circle-pause.svg")
        },
        {
            name: "Lock",
            action: "lock",
            iconSize: 26,
            icon: Qt.resolvedUrl("../Assets/Icons/lucide/lock.svg")
        },
        {
            name: "Restart",
            action: "reboot",
            iconSize: 28,
            icon: Qt.resolvedUrl("../Assets/Icons/lucide/rotate-ccw.svg")
        }
    ]

    function selectOffset(offset: int): void {
        root.selectedIndex = (root.selectedIndex + offset + root.actions.length)
            % root.actions.length
    }

    function activateSelected(): void {
        PowerMenuService.trigger(root.actions[root.selectedIndex].action)
    }

    Keys.onLeftPressed: event => {
        root.selectOffset(-1)
        event.accepted = true
    }

    Keys.onRightPressed: event => {
        root.selectOffset(1)
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        root.activateSelected()
        event.accepted = true
    }

    Keys.onEnterPressed: event => {
        root.activateSelected()
        event.accepted = true
    }

    Keys.onSpacePressed: event => {
        root.activateSelected()
        event.accepted = true
    }

    Keys.onEscapePressed: event => {
        PowerMenuService.closeMenu()
        event.accepted = true
    }

    Item {
        id: actionStrip
        width: Theme.sessionButtonSize * root.actions.length
            + Theme.sessionButtonSpacing * (root.actions.length - 1)
        height: Theme.sessionButtonSize
        anchors.centerIn: parent

        Rectangle {
            id: selection
            z: 0
            x: root.selectedIndex * (Theme.sessionButtonSize + Theme.sessionButtonSpacing)
            width: Theme.sessionButtonSize
            height: Theme.sessionButtonSize
            radius: width / 2
            color: Theme.sessionSelectionColor

            transform: Scale {
                id: selectionScale
                origin.x: selection.width / 2
                origin.y: selection.height / 2
            }

            Behavior on x {
                SpringAnimation {
                    spring: 4.5
                    damping: 0.42
                    epsilon: 0.15
                }
            }
        }

        SequentialAnimation {
            id: rollFeedback

            ParallelAnimation {
                NumberAnimation {
                    target: selectionScale
                    property: "xScale"
                    to: 1.12
                    duration: 85
                    easing.type: Easing.OutQuad
                }

                NumberAnimation {
                    target: selectionScale
                    property: "yScale"
                    to: 0.9
                    duration: 85
                    easing.type: Easing.OutQuad
                }
            }

            ParallelAnimation {
                SpringAnimation {
                    target: selectionScale
                    property: "xScale"
                    to: 1
                    spring: 5
                    damping: 0.5
                }

                SpringAnimation {
                    target: selectionScale
                    property: "yScale"
                    to: 1
                    spring: 5
                    damping: 0.5
                }
            }
        }

        Row {
            z: 1
            spacing: Theme.sessionButtonSpacing

            Repeater {
                model: root.actions

                Item {
                    required property var modelData
                    required property int index

                    width: Theme.sessionButtonSize
                    height: Theme.sessionButtonSize

                    ColorizedIcon {
                        anchors.centerIn: parent
                        width: modelData.iconSize
                        height: modelData.iconSize
                        source: modelData.icon
                        color: root.selectedIndex === index
                            ? Theme.backgroundColor
                            : Theme.sessionIconColor

                        Behavior on color {
                            ColorAnimation { duration: Theme.contentTransitionDuration }
                        }
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                        onHoveredChanged: {
                            if (hovered)
                                root.selectedIndex = index
                        }
                    }

                    TapHandler {
                        onTapped: PowerMenuService.trigger(modelData.action)
                    }
                }
            }
        }
    }

    Connections {
        target: PowerMenuService

        function onVisibleChanged() {
            if (!PowerMenuService.visible)
                return

            root.selectedIndex = 0
            Qt.callLater(root.forceActiveFocus)
        }
    }

    onSelectedIndexChanged: rollFeedback.restart()
}
