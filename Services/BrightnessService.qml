pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    signal brightnessUpdated()

    readonly property real minimumBrightness: 0.01
    property real brightness: 0
    property bool initialized: false
    property real pendingBrightness: -1

    function applyOutput(output: string): void {
        const fields = output.trim().split(",")
        if (fields.length < 4)
            return

        const percentage = parseFloat(fields[3]) / 100
        if (!Number.isFinite(percentage))
            return

        const changed = root.initialized && Math.abs(percentage - root.brightness) > 0.0001
        root.brightness = percentage

        if (!root.initialized) {
            root.initialized = true
            return
        }

        if (changed)
            root.brightnessUpdated()
    }

    function refresh(): void {
        if (!queryProcess.running)
            queryProcess.exec(["brightnessctl", "-m"])
    }

    function setBrightness(value: real): void {
        const clamped = Math.max(root.minimumBrightness, Math.min(1, value))
        root.brightness = clamped
        root.pendingBrightness = clamped
        writeTimer.restart()
    }

    function commitPendingBrightness(): void {
        if (root.pendingBrightness < 0)
            return

        if (writeProcess.running) {
            writeTimer.restart()
            return
        }

        const percentage = Math.round(root.pendingBrightness * 100)
        root.pendingBrightness = -1
        writeProcess.exec(["brightnessctl", "set", percentage + "%"])
    }

    Process {
        id: queryProcess

        stdout: StdioCollector {
            onStreamFinished: {
                if (root.pendingBrightness < 0 && !writeProcess.running)
                    root.applyOutput(text)
            }
        }
    }

    Process {
        id: writeProcess

        onExited: {
            if (root.pendingBrightness >= 0)
                writeTimer.restart()
            else
                root.refresh()
        }
    }

    Timer {
        id: writeTimer
        interval: 40
        onTriggered: root.commitPendingBrightness()
    }

    Timer {
        interval: 350
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
