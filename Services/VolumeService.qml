// VolumeService.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    signal audioUpdated()

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property PwNode defaultSink: Pipewire.defaultAudioSink
    readonly property PwNodeAudio audio: defaultSink?.audio ?? null
    readonly property bool ready: defaultSink?.ready ?? false
    readonly property real maximumVolume: 1.5

    readonly property real volume: audio?.volume ?? 0
    readonly property bool muted: audio?.muted ?? false

    Connections {
        target: root.audio

        function onVolumeChanged() {
            if (!root.ready)
                return

            root.audioUpdated()
        }

        function onMutedChanged() {
            if (!root.ready)
                return

            root.audioUpdated()
        }
    }

    function setVolume(volume: real) {
        if (root.ready && root.audio)
            root.audio.volume = Math.max(0, Math.min(root.maximumVolume, volume))
    }

    function setMuted(muted: bool) {
        if (root.ready && root.audio)
            root.audio.muted = muted
    }

    function toggleMuted() {
        root.setMuted(!root.muted)
    }
}
