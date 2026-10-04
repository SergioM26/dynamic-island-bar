// VolumeService.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    signal volumeUpdated()

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property PwNode defaultSink: Pipewire.defaultAudioSink
    readonly property PwNodeAudio audio: defaultSink?.audio ?? null
    readonly property bool ready: defaultSink?.ready ?? false

    readonly property real volume: audio?.volume ?? 0

    Connections {
        target: root.audio

        function onVolumeChanged() {
            if (!root.ready)
                return

            root.volumeUpdated()
        }
    }

    function setVolume(volume: real) {
        if (root.ready && root.audio)
            root.audio.volume = Math.max(0, Math.min(1, volume))
    }
}
