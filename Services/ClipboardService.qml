pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../Config"

Singleton {
    id: root

    property bool visible: false
    property bool loading: false
    property string hostMonitorName: ""
    property var entries: []
    property int resultCount: 0
    property string pendingId: ""

    function show(): void {
        if (!Settings.enableClipboard)
            return

        FocusService.capture()
        root.hostMonitorName = Hyprland.focusedMonitor?.name ?? ""
        root.visible = true
        FocusService.hold()
        root.refresh()
    }

    function close(): void {
        root.visible = false
        FocusService.restoreDelayed()
    }

    function toggle(): void {
        if (root.visible)
            root.close()
        else
            root.show()
    }

    function refresh(): void {
        if (!Settings.enableClipboard)
            return

        root.loading = true
        listProcess.exec(["cliphist", "list"])
    }

    function parseList(output: string): void {
        const parsed = []
        const lines = output.split("\n")

        for (const line of lines) {
            const separator = line.indexOf("\t")
            if (separator < 1)
                continue

            const id = line.slice(0, separator)
            const preview = line.slice(separator + 1).trim()
            const binary = preview.startsWith("[[ binary data ")
            parsed.push({
                id: id,
                preview: preview,
                binary: binary,
                display: binary
                    ? preview.replace(/^\[\[ binary data /, "")
                        .replace(/ \]\]$/, "")
                        .replace(/\bpng\b/i, "PNG")
                    : preview
            })
        }

        root.entries = parsed
        root.loading = false
    }

    function copy(entry: var): void {
        if (!Settings.enableClipboard || !entry)
            return

        root.pendingId = entry.id
        root.visible = false
        FocusService.restoreDelayed()
        copyDelay.restart()
    }

    function copyPending(): void {
        const id = root.pendingId
        root.pendingId = ""
        if (id.length === 0)
            return

        Quickshell.execDetached([
            "sh", "-c", "cliphist decode \"$1\" | wl-copy", "cliphist-copy", id
        ])
    }

    function remove(entry: var): void {
        if (!Settings.enableClipboard || !entry || deleteProcess.running)
            return

        deleteProcess.exec([
            "sh", "-c", "printf '%s\\n' \"$1\" | cliphist delete",
            "cliphist-delete", entry.id
        ])
    }

    IpcHandler {
        target: "clipboard"

        function toggle(): void { root.toggle() }
        function open(): void { root.show() }
        function close(): void { root.close() }
    }

    Process {
        id: listProcess
        stdout: StdioCollector {
            onStreamFinished: root.parseList(text)
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                root.loading = false
        }
    }

    Process {
        id: deleteProcess
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0)
                root.refresh()
        }
    }

    Timer {
        id: copyDelay
        interval: Theme.contentTransitionDuration + Theme.morphDuration
        onTriggered: root.copyPending()
    }
}
