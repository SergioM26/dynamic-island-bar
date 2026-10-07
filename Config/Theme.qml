pragma Singleton

import QtQuick

QtObject {
    // Island geometry
    readonly property real idleWidth: 120
    readonly property real idleHeight: 40
    readonly property real expandedWidth: 300
    readonly property real expandedHeight: 80
    readonly property real controlWidth: 240
    readonly property real controlHeight: 40
    readonly property real authenticationWidth: 440
    readonly property real authenticationHeight: 230
    readonly property real authenticationRadius: 24
    readonly property real sessionWidth: 300
    readonly property real sessionHeight: 68
    readonly property real islandTopMargin: 5
    readonly property real exclusiveZone: 40

    // Motion
    readonly property int morphDuration: 320
    readonly property int contentTransitionDuration: 140
    readonly property int detailTransitionDuration: 200
    readonly property int colorTransitionDuration: 300

    // Colors
    readonly property color backgroundColor: "black"
    readonly property color foregroundColor: "white"
    readonly property color sliderTrackColor: "gray"
    readonly property color sliderProgressColor: "white"
    readonly property color batteryNormalColor: "black"
    readonly property color batteryChargingColor: "lime"
    readonly property color batteryLowColor: "red"
    readonly property color batteryWarningColor: "yellow"
    readonly property color secondaryTextColor: "#a0a0a0"
    readonly property color errorColor: "#ff5f5f"
    readonly property color buttonColor: "#202020"
    readonly property color buttonHoverColor: "#303030"
    readonly property color selectionColor: "#d0d0d0"
    readonly property color sessionSelectionColor: "#f5f5f5"
    readonly property color sessionIconColor: "white"
    readonly property color modalScrimColor: "#4d000000"

    // Typography
    readonly property string fontFamily: "monospace"
    readonly property real clockFontSize: 16
    readonly property real expandedClockFontSize: 20
    readonly property real dateFontSize: 14
    readonly property real authenticationTitleFontSize: 18
    readonly property real authenticationDetailFontSize: 11
    readonly property real authenticationInputFontSize: 14
    readonly property real buttonFontSize: 12

    // Surface
    readonly property real borderWidth: 2
    readonly property real shadowBlur: 0.8
    readonly property real shadowOpacity: 0.8
    readonly property real shadowVerticalOffset: 2

    // Authentication
    readonly property real authenticationContentWidth: 340
    readonly property real authenticationElementSpacing: 12
    readonly property real authenticationSectionSpacing: 18
    readonly property real authenticationInputHeight: 44
    readonly property real authenticationInputPadding: 14
    readonly property real authenticationPasswordSpacing: 3
    readonly property real authenticationLockSize: 18
    readonly property real authenticationButtonHeight: 38
    readonly property real authenticationErrorHeight: 16

    // Session menu
    readonly property real sessionButtonSize: 46
    readonly property real sessionButtonSpacing: 18

    // Sliders
    readonly property real sliderTrackWidth: 150
    readonly property real sliderHeight: 15
    readonly property real sliderIconSize: 18
    readonly property real sliderSpacing: 8
    readonly property real sliderIconHitSize: 24
    readonly property real sliderWidth: sliderIconSize + sliderSpacing + sliderTrackWidth
    readonly property real mutedSliderOpacity: 0.35
    readonly property real sliderValueSpacing: 4
    readonly property real sliderValueWidth: 36
    readonly property real sliderValueFontSize: 14
    readonly property real systemControlWidth: sliderWidth + sliderValueSpacing + sliderValueWidth
}
