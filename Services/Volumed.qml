// Volumed.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id : volumed 

    signal volumeUpdated()

    property bool initialized: false

    Timer {
        interval: 500
        running: true
        repeat: false
        onTriggered: volumed.initialized = true
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property PwNode defaultSink: Pipewire.defaultAudioSink

    property real volume:
        defaultSink?.audio?.volume ?? 0

    Connections {
        target : volumed.defaultSink?.audio ?? null

        function onVolumeChanged() {
            if (!volumed.initialized)
                return

            console.log("Volume:", volumed.volume)
            volumed.volumeUpdated()
        }
    }

    function setVolume(vol: real){
        if(defaultSink?.audio)
            defaultSink.audio.volume = vol
    }
}
