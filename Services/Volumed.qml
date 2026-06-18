// Volumed.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id : volumed 

    signal volumeUpdated()

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property PwNode defaultSink: Pipewire.defaultAudioSink

    property real volume:
        defaultSink?.audio?.volume ?? -1

    Connections {
        target : volumed.defaultSink?.audio ?? null

        function onVolumeChanged() {
            console.log("Volume:", volumed.volume)
            volumed.volumeUpdated()
        }
    }

    function setVolume(vol: real){
        if(defaultSink?.audio)
            defaultSink.audio.volume = vol
    }
}
