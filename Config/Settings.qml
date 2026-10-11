pragma Singleton

import QtQuick

QtObject {
    // Optional features
    readonly property bool enableApplicationLauncher: true
    readonly property bool enableClipboard: true
    readonly property bool enablePowerMenu: true
    readonly property bool enablePowerProfiles: true
    readonly property bool enablePolkit: true
    readonly property bool enableExternalBrightness: true

    // Displays
    readonly property string internalMonitorName: "eDP-1"

    // Interface
    readonly property real uiScale: 1.0

    // Transient island feedback
    readonly property bool enableVolumeFeedback: true
    readonly property bool enableBrightnessFeedback: true
    readonly property bool enableWorkspaceFeedback: false

    // Application launcher
    readonly property var terminalCommand: ["ghostty", "-e"]

    // System controls
    readonly property real maximumVolume: 1.5
    readonly property real brightnessStep: 0.05
}
