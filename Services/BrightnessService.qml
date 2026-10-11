pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../Config"

Singleton {
    id: root

    signal brightnessUpdated()

    readonly property real minimumBrightness: 0.01
    readonly property real adjustmentStep: Settings.brightnessStep
    readonly property string activeMonitorName:
        Hyprland.focusedMonitor?.name ?? root.internalMonitorName
    readonly property bool activeIsInternal:
        root.activeMonitorName === root.internalMonitorName
    readonly property bool activeIsExternal:
        Settings.enableExternalBrightness
        && root.activeMonitorName === root.externalMonitorName
        && root.externalMonitorName.length > 0
    readonly property bool externalAvailable:
        Settings.enableExternalBrightness && root.externalMonitorName.length > 0
    readonly property real brightness:
        root.activeIsExternal ? root.externalBrightness : root.internalBrightness

    readonly property string internalMonitorName: Settings.internalMonitorName
    property string externalMonitorName: ""
    property string externalSerial: ""
    property string externalBus: ""

    property real internalBrightness: 0
    property real externalBrightness: 0
    property bool internalInitialized: false
    property bool externalInitialized: false
    property real pendingInternalBrightness: -1
    property real pendingExternalBrightness: -1

    function externalSelector(): list<string> {
        if (root.externalBus.length > 0)
            return ["--bus", root.externalBus]
        if (root.externalSerial.length > 0)
            return ["--sn", root.externalSerial]
        return []
    }

    function applyInternalOutput(output: string): void {
        const fields = output.trim().split(",")
        if (fields.length < 4)
            return

        const percentage = parseFloat(fields[3]) / 100
        if (!Number.isFinite(percentage))
            return

        const changed = root.internalInitialized
            && Math.abs(percentage - root.internalBrightness) > 0.0001
        root.internalBrightness = percentage

        if (!root.internalInitialized) {
            root.internalInitialized = true
            return
        }

        if (changed && !root.activeIsExternal)
            root.brightnessUpdated()
    }

    function applyExternalOutput(output: string): void {
        const match = output.match(/VCP\s+10\s+C\s+(\d+)\s+(\d+)/)
        if (!match)
            return

        const current = parseFloat(match[1])
        const maximum = parseFloat(match[2])
        if (!Number.isFinite(current) || !Number.isFinite(maximum) || maximum <= 0)
            return

        const percentage = current / maximum
        const changed = root.externalInitialized
            && Math.abs(percentage - root.externalBrightness) > 0.0001
        root.externalBrightness = percentage

        if (!root.externalInitialized) {
            root.externalInitialized = true
            return
        }

        if (changed && root.activeIsExternal)
            root.brightnessUpdated()
    }

    function applyDetection(output: string): void {
        if (!Settings.enableExternalBrightness)
            return

        let displayValid = false
        let bus = ""
        let connector = ""
        let serial = ""

        function commitDisplay(): void {
            if (!displayValid || connector.length === 0 || connector.startsWith("eDP-"))
                return

            root.externalMonitorName = connector
            root.externalSerial = serial
            root.externalBus = bus
        }

        for (const rawLine of output.split("\n")) {
            const line = rawLine.trim()

            if (/^Display\s+\d+/.test(line)) {
                commitDisplay()
                displayValid = true
                bus = ""
                connector = ""
                serial = ""
                continue
            }

            if (line.startsWith("Invalid display")) {
                commitDisplay()
                displayValid = false
                continue
            }

            if (!displayValid)
                continue

            let match = line.match(/^I2C bus:\s*\/dev\/i2c-(\d+)/)
            if (match) {
                bus = match[1]
                continue
            }

            match = line.match(/^DRM connector:\s*card\d+-(.+)/)
            if (match) {
                connector = match[1]
                continue
            }

            match = line.match(/^Monitor:\s*[^:]*:[^:]*:(.*)$/)
            if (match)
                serial = match[1].trim()
        }

        commitDisplay()

        if (root.externalAvailable)
            root.refreshExternal()
    }

    function refreshInternal(): void {
        if (!internalQuery.running)
            internalQuery.exec(["brightnessctl", "-m"])
    }

    function refreshExternal(): void {
        if (!Settings.enableExternalBrightness
                || !root.externalAvailable
                || externalQuery.running
                || externalWrite.running)
            return

        externalQuery.exec(
            ["ddcutil"].concat(root.externalSelector(), ["getvcp", "10", "--terse"])
        )
    }

    function refreshActive(): void {
        if (root.activeIsExternal) {
            root.refreshExternal()
        } else if (root.activeIsInternal) {
            root.refreshInternal()
        } else if (Settings.enableExternalBrightness && !detectProcess.running) {
            detectProcess.exec(["ddcutil", "detect", "--brief"])
        }
    }

    function setBrightness(value: real): void {
        const clamped = Math.max(root.minimumBrightness, Math.min(1, value))

        if (root.activeIsExternal) {
            root.externalBrightness = clamped
            root.externalInitialized = true
            root.pendingExternalBrightness = clamped
            externalWriteTimer.restart()
        } else if (root.activeIsInternal) {
            root.internalBrightness = clamped
            root.internalInitialized = true
            root.pendingInternalBrightness = clamped
            internalWriteTimer.restart()
        }
    }

    function adjustBrightness(offset: real): void {
        if (!root.activeIsInternal && !root.activeIsExternal) {
            root.refreshActive()
            return
        }

        if (root.activeIsExternal && !root.externalInitialized) {
            root.refreshExternal()
            return
        }

        if (!root.activeIsExternal && !root.internalInitialized) {
            root.refreshInternal()
            return
        }

        root.setBrightness(root.brightness + offset)
        root.brightnessUpdated()
    }

    function commitInternalBrightness(): void {
        if (root.pendingInternalBrightness < 0)
            return

        if (internalWrite.running) {
            internalWriteTimer.restart()
            return
        }

        const percentage = Math.round(root.pendingInternalBrightness * 100)
        root.pendingInternalBrightness = -1
        internalWrite.exec(["brightnessctl", "set", percentage + "%"])
    }

    function commitExternalBrightness(): void {
        if (root.pendingExternalBrightness < 0 || !root.externalAvailable)
            return

        if (externalWrite.running) {
            externalWriteTimer.restart()
            return
        }

        const percentage = Math.round(root.pendingExternalBrightness * 100)
        root.pendingExternalBrightness = -1
        externalWrite.exec(
            ["ddcutil"].concat(
                root.externalSelector(),
                ["setvcp", "10", percentage.toString(), "--noverify"]
            )
        )
    }

    IpcHandler {
        target: "brightness"

        function increase(): void { root.adjustBrightness(root.adjustmentStep) }
        function decrease(): void { root.adjustBrightness(-root.adjustmentStep) }
        function refresh(): void { root.refreshActive() }
        function getMonitor(): string { return root.activeMonitorName }
        function getBackend(): string {
            if (root.activeIsExternal)
                return "ddcutil"
            if (root.activeIsInternal)
                return "brightnessctl"
            return "unavailable"
        }
        function getValue(): real { return root.brightness }
    }

    Connections {
        target: Hyprland
        function onFocusedMonitorChanged(): void { root.refreshActive() }
    }

    Process {
        id: detectProcess
        command: ["ddcutil", "detect", "--brief"]
        running: Settings.enableExternalBrightness
        stdout: StdioCollector {
            onStreamFinished: root.applyDetection(text)
        }
    }

    Process {
        id: internalQuery
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.pendingInternalBrightness < 0 && !internalWrite.running)
                    root.applyInternalOutput(text)
            }
        }
    }

    Process {
        id: internalWrite
        onExited: {
            if (root.pendingInternalBrightness >= 0)
                internalWriteTimer.restart()
            else
                root.refreshInternal()
        }
    }

    Process {
        id: externalQuery
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.pendingExternalBrightness < 0 && !externalWrite.running)
                    root.applyExternalOutput(text)
            }
        }
    }

    Process {
        id: externalWrite
        onExited: {
            if (root.pendingExternalBrightness >= 0)
                externalWriteTimer.restart()
            else
                root.refreshExternal()
        }
    }

    Timer {
        id: internalWriteTimer
        interval: 40
        onTriggered: root.commitInternalBrightness()
    }

    Timer {
        id: externalWriteTimer
        interval: 500
        onTriggered: root.commitExternalBrightness()
    }

    Timer {
        interval: 350
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshInternal()
    }

}
