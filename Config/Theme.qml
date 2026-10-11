pragma Singleton

import QtQuick

QtObject {
    readonly property real uiScale: Math.max(0.5, Settings.uiScale)

    // Island geometry
    readonly property real idleWidth: 120 * uiScale
    readonly property real idleHeight: 40 * uiScale
    readonly property real expandedWidth: 300 * uiScale
    readonly property real expandedHeight: 80 * uiScale
    readonly property real controlWidth: 240 * uiScale
    readonly property real controlHeight: 40 * uiScale
    readonly property real workspaceSize: 40 * uiScale
    readonly property real authenticationWidth: 440 * uiScale
    readonly property real authenticationHeight: 230 * uiScale
    readonly property real authenticationRadius: 24 * uiScale
    readonly property real sessionWidth: 300 * uiScale
    readonly property real sessionHeight: 92 * uiScale
    readonly property real powerProfileWidth: 238 * uiScale
    readonly property real powerProfileHeight: 92 * uiScale
    readonly property real launcherWidth: 540 * uiScale
    readonly property real launcherHeaderHeight: 66 * uiScale
    readonly property real launcherBottomPadding: 12 * uiScale
    readonly property real launcherListTopPadding: 8 * uiScale
    readonly property real launcherRowHeight: 44 * uiScale
    readonly property int launcherMaximumRows: 6
    readonly property real launcherRadius: 28 * uiScale
    readonly property real islandTopMargin: 5 * uiScale
    readonly property real screenEdgeMargin: 16 * uiScale
    readonly property real exclusiveZone: 40 * uiScale

    // Motion
    readonly property int morphDuration: 320
    readonly property int contentTransitionDuration: 140
    readonly property int detailTransitionDuration: 200
    readonly property int colorTransitionDuration: 300
    readonly property int optionCenterDuration: 280
    readonly property int optionConfirmHoldDuration: 250
    readonly property int optionConfirmDuration:
        optionCenterDuration + morphDuration + optionConfirmHoldDuration

    // Colors
    readonly property color backgroundColor: "black"
    readonly property color foregroundColor: "white"
    readonly property color sliderTrackColor: "gray"
    readonly property color sliderProgressColor: "white"
    readonly property color sliderThumbColor: "#FAFAFA"
    readonly property color sliderThumbBorderColor: "#666666"
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
    readonly property color thumbnailBorderColor: "#383838"

    // Typography
    readonly property string fontFamily: "monospace"
    readonly property real clockFontSize: 16 * uiScale
    readonly property real expandedClockFontSize: 20 * uiScale
    readonly property real dateFontSize: 14 * uiScale
    readonly property real workspaceFontSize: 18 * uiScale
    readonly property real authenticationTitleFontSize: 18 * uiScale
    readonly property real authenticationDetailFontSize: 11 * uiScale
    readonly property real authenticationInputFontSize: 14 * uiScale
    readonly property real buttonFontSize: 12 * uiScale
    readonly property real buttonHorizontalPadding: 14 * uiScale
    readonly property real buttonHeight: 34 * uiScale
    readonly property real buttonRadius: 10 * uiScale
    readonly property real optionLabelFontSize: 14 * uiScale
    readonly property real launcherInputFontSize: 18 * uiScale
    readonly property real launcherCounterFontSize: 12 * uiScale
    readonly property real launcherRowFontSize: 15 * uiScale
    readonly property real launcherDescriptionFontSize: 11 * uiScale
    readonly property real launcherFallbackIconFontSize: 15 * uiScale

    // Surface
    readonly property real borderWidth: 2 * uiScale
    readonly property real shadowBlur: 0.8
    readonly property real shadowOpacity: 0.55
    readonly property real shadowVerticalOffset: 2 * uiScale

    // Authentication
    readonly property real authenticationContentWidth: 340 * uiScale
    readonly property real authenticationElementSpacing: 12 * uiScale
    readonly property real authenticationTextSpacing: 6 * uiScale
    readonly property real authenticationSectionSpacing: 18 * uiScale
    readonly property real authenticationInputHeight: 44 * uiScale
    readonly property real authenticationInputPadding: 14 * uiScale
    readonly property real authenticationPasswordSpacing: 3 * uiScale
    readonly property real authenticationLockSize: 18 * uiScale
    readonly property real authenticationButtonHeight: 38 * uiScale
    readonly property real authenticationErrorHeight: 16 * uiScale

    // Session menu
    readonly property real sessionButtonSize: 46 * uiScale
    readonly property real sessionButtonSpacing: 18 * uiScale
    readonly property real optionStripHeight: 92 * uiScale
    readonly property real optionStripTopPadding: 11 * uiScale
    readonly property real optionStripLabelTop: 64 * uiScale
    readonly property real optionConfirmWidth: 200 * uiScale
    readonly property real optionConfirmHeight: optionStripHeight

    // App launcher
    readonly property real launcherHorizontalPadding: 28 * uiScale
    readonly property real launcherInputTop: 20 * uiScale
    readonly property real launcherInputHeight: 34 * uiScale
    readonly property real launcherSearchIconSize: 20 * uiScale
    readonly property real launcherSearchSpacing: 12 * uiScale
    readonly property real launcherAppIconSize: 26 * uiScale
    readonly property real launcherRowHorizontalPadding: 12 * uiScale
    readonly property real launcherRowContentSpacing: 12 * uiScale
    readonly property real launcherRowRadius: 9 * uiScale
    readonly property real launcherIconRadius: 6 * uiScale
    readonly property real launcherSeparatorHeight: Math.max(1, uiScale)
    readonly property real launcherDescriptionWidth: 150 * uiScale
    readonly property real launcherScrollbarWidth: 4 * uiScale
    readonly property real launcherScrollbarSpacing: 10 * uiScale
    readonly property real launcherScrollbarMinHeight: 28 * uiScale
    readonly property real clipboardPreviewSize: 30 * uiScale
    readonly property real clipboardBadgeFontSize: 9 * uiScale
    readonly property real thumbnailBorderWidth: Math.max(1, uiScale)

    // Sliders
    readonly property real sliderTrackWidth: 150 * uiScale
    readonly property real sliderHeight: 15 * uiScale
    readonly property real sliderThumbWidth: 10 * uiScale
    readonly property real sliderThumbHeight: 24 * uiScale
    readonly property real sliderThumbBorderWidth: 2 * uiScale
    readonly property real sliderIconSize: 18 * uiScale
    readonly property real sliderSpacing: 8 * uiScale
    readonly property real sliderIconHitSize: 24 * uiScale
    readonly property real sliderWidth: sliderIconSize + sliderSpacing + sliderTrackWidth
    readonly property real mutedSliderOpacity: 0.35
    readonly property real sliderValueSpacing: 4 * uiScale
    readonly property real sliderValueWidth: 36 * uiScale
    readonly property real sliderValueFontSize: 14 * uiScale
    readonly property real systemControlWidth: sliderWidth + sliderValueSpacing + sliderValueWidth
}
