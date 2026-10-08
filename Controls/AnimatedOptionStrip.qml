import QtQuick
import "../Components"
import "../Config"

FocusScope {
    id: root

    required property var options
    property int selectedIndex: 0
    property bool confirming: false
    signal activated(int index)
    signal confirmationStarted()
    signal cancelRequested()

    readonly property real contentWidth: Theme.sessionButtonSize * options.length
        + Theme.sessionButtonSpacing * (options.length - 1)
    implicitWidth: contentWidth
    implicitHeight: Theme.optionStripHeight

    function requestActivation(index: int): void {
        if (confirming)
            return

        selectedIndex = index
        confirmationStarted()
        confirmationTimer.restart()
    }

    function selectOffset(offset: int): void {
        selectedIndex = (selectedIndex + offset + options.length) % options.length
    }

    Keys.onLeftPressed: event => {
        if (!confirming) selectOffset(-1)
        event.accepted = true
    }
    Keys.onRightPressed: event => {
        if (!confirming) selectOffset(1)
        event.accepted = true
    }
    Keys.onTabPressed: event => {
        if (!confirming) selectOffset(1)
        event.accepted = true
    }
    Keys.onBacktabPressed: event => {
        if (!confirming) selectOffset(-1)
        event.accepted = true
    }
    Keys.onReturnPressed: event => { requestActivation(selectedIndex); event.accepted = true }
    Keys.onEnterPressed: event => { requestActivation(selectedIndex); event.accepted = true }
    Keys.onSpacePressed: event => { requestActivation(selectedIndex); event.accepted = true }
    Keys.onEscapePressed: event => {
        if (!confirming) cancelRequested()
        event.accepted = true
    }

    readonly property real iconTop: Theme.optionStripTopPadding

    Rectangle {
        id: selection
        z: 0
        x: (root.width - root.contentWidth) / 2
            + root.selectedIndex * (Theme.sessionButtonSize + Theme.sessionButtonSpacing)
        y: root.iconTop
        width: Theme.sessionButtonSize
        height: Theme.sessionButtonSize
        radius: width / 2
        color: Theme.sessionSelectionColor
        opacity: root.confirming ? 0 : 1

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
        Behavior on opacity {
            NumberAnimation { duration: Theme.contentTransitionDuration }
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
        id: optionRow
        z: 1
        x: (root.width - root.contentWidth) / 2
        y: root.iconTop
        spacing: Theme.sessionButtonSpacing

        Repeater {
            model: root.options

            Item {
                required property var modelData
                required property int index
                width: Theme.sessionButtonSize
                height: Theme.sessionButtonSize
                opacity: root.confirming ? 0 : 1

                Behavior on opacity {
                    NumberAnimation { duration: Theme.contentTransitionDuration }
                }

                ColorizedIcon {
                    anchors.centerIn: parent
                    width: modelData.iconSize
                    height: modelData.iconSize
                    source: modelData.icon
                    color: root.selectedIndex === index && !root.confirming
                        ? Theme.backgroundColor
                        : Theme.sessionIconColor

                    Behavior on color {
                        ColorAnimation { duration: Theme.contentTransitionDuration }
                    }
                }

                HoverHandler {
                    enabled: !root.confirming
                    cursorShape: Qt.PointingHandCursor
                    onHoveredChanged: {
                        if (hovered)
                            root.selectedIndex = index
                    }
                }

                TapHandler {
                    enabled: !root.confirming
                    onTapped: root.requestActivation(index)
                }
            }
        }
    }

    ColorizedIcon {
        id: confirmationIcon
        z: 2
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.iconTop + (Theme.sessionButtonSize - height) / 2
        width: root.options[root.selectedIndex]?.iconSize ?? 0
        height: width
        source: root.options[root.selectedIndex]?.icon ?? ""
        color: Theme.sessionIconColor
        visible: opacity > 0
        opacity: root.confirming ? 1 : 0

        transform: Translate {
            x: root.confirming ? 0
                : optionRow.x
                    + root.selectedIndex
                        * (Theme.sessionButtonSize + Theme.sessionButtonSpacing)
                    + Theme.sessionButtonSize / 2
                    - root.width / 2

            Behavior on x {
                NumberAnimation {
                    duration: Theme.optionCenterDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: Theme.contentTransitionDuration }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.optionStripLabelTop
        text: root.confirming
            ? root.options[root.selectedIndex]?.confirmationLabel
                ?? root.options[root.selectedIndex]?.name
                ?? ""
            : root.options[root.selectedIndex]?.name ?? ""
        color: Theme.foregroundColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.optionLabelFontSize
    }

    Timer {
        id: confirmationTimer
        interval: Theme.optionConfirmDuration
        onTriggered: root.activated(root.selectedIndex)
    }

    onSelectedIndexChanged: {
        if (!confirming)
            rollFeedback.restart()
    }

    onConfirmingChanged: {
        if (!confirming)
            confirmationTimer.stop()
    }
}
