import QtQuick
import "../Components"
import "../Controls"
import "../Services"
import "../Config"

FocusScope {
    id: root

    readonly property var flow: PolkitService.flow
    property string fallbackError: ""

    function focusInput(): void {
        if (flow?.isResponseRequired)
            responseInput.forceActiveFocus()
    }

    function clearInput(): void {
        responseInput.clear()
    }

    function submit(): void {
        if (!flow?.isResponseRequired)
            return

        root.fallbackError = ""
        const response = responseInput.text
        responseInput.clear()
        PolkitService.submit(response)
    }

    function cancel(): void {
        responseInput.clear()
        PolkitService.cancel()
    }

    Keys.onEscapePressed: event => {
        root.cancel()
        event.accepted = true
    }

    Column {
        anchors.centerIn: parent
        width: Theme.authenticationContentWidth
        spacing: Theme.authenticationSectionSpacing

        Column {
            width: parent.width
            spacing: 6

            Text {
                width: parent.width
                text: "Authentication Required"
                color: Theme.foregroundColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.authenticationTitleFontSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width
                text: root.flow?.message ?? "An application requires authorization."
                color: Theme.secondaryTextColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.authenticationDetailFontSize
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
            }
        }

        Column {
            width: parent.width
            spacing: Theme.authenticationElementSpacing

            Rectangle {
                width: parent.width
                height: Theme.authenticationInputHeight
                radius: height / 2
                color: responseInput.activeFocus
                    ? Theme.buttonHoverColor
                    : Theme.buttonColor
                visible: root.flow?.isResponseRequired ?? false

                ColorizedIcon {
                    id: lockIcon
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.authenticationInputPadding
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.authenticationLockSize
                    height: Theme.authenticationLockSize
                    source: "../Assets/Icons/lucide/lock.svg"
                    color: Theme.foregroundColor
                }

                Text {
                    anchors.left: lockIcon.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.flow?.inputPrompt ?? "Password"
                    color: Theme.secondaryTextColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.authenticationInputFontSize
                    visible: responseInput.text.length === 0
                }

                TextInput {
                    id: responseInput
                    anchors.left: lockIcon.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.authenticationInputPadding
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: Theme.foregroundColor
                    selectionColor: Theme.selectionColor
                    selectedTextColor: Theme.backgroundColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.authenticationInputFontSize
                    font.letterSpacing: echoMode === TextInput.Password
                        ? Theme.authenticationPasswordSpacing
                        : 0
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: root.flow?.responseVisible ? TextInput.Normal : TextInput.Password
                    enabled: root.flow?.isResponseRequired ?? false
                    clip: true

                    Keys.onReturnPressed: event => {
                        root.submit()
                        event.accepted = true
                    }
                }
            }

            Text {
                width: parent.width
                height: Theme.authenticationErrorHeight
                text: root.flow?.supplementaryMessage || root.fallbackError
                color: (root.flow?.supplementaryIsError || root.fallbackError.length > 0)
                    ? Theme.errorColor
                    : Theme.secondaryTextColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.authenticationDetailFontSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                visible: text.length > 0
            }

            Row {
                width: parent.width
                spacing: Theme.authenticationElementSpacing

                ActionButton {
                    width: (parent.width - parent.spacing) / 2
                    height: Theme.authenticationButtonHeight
                    label: "Cancel"
                    onClicked: root.cancel()
                }

                ActionButton {
                    width: (parent.width - parent.spacing) / 2
                    height: Theme.authenticationButtonHeight
                    label: "Authenticate"
                    primary: true
                    enabled: root.flow?.isResponseRequired ?? false
                    opacity: enabled ? 1 : 0.5
                    onClicked: root.submit()
                }
            }
        }
    }

    Connections {
        target: PolkitService

        function onAuthenticationStarted() {
            root.fallbackError = ""
            root.clearInput()
            Qt.callLater(root.focusInput)
        }

        function onAuthenticationEnded() {
            root.fallbackError = ""
            root.clearInput()
        }
    }

    Connections {
        target: root.flow

        function onIsResponseRequiredChanged() {
            root.clearInput()
            Qt.callLater(root.focusInput)
        }

        function onAuthenticationFailed() {
            root.fallbackError = "Authentication failed. Please try again."
            root.clearInput()
            Qt.callLater(root.focusInput)
        }
    }
}
