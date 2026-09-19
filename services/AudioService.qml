import QtQuick 2.15
import Quickshell
import Quickshell.Services.Pipewire

// AudioService — PipeWire audio sink and source monitor using native Quickshell Pipewire service
Item {
    id: root

    // Active sink (speaker / output) properties
    readonly property real volume: (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) 
                                    ? Pipewire.defaultAudioSink.audio.volume : 0.0
    readonly property bool isMuted: (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) 
                                    ? Pipewire.defaultAudioSink.audio.muted : false

    // Active source (microphone / input) properties
    readonly property real micVolume: (Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio) 
                                      ? Pipewire.defaultAudioSource.audio.volume : 0.0
    readonly property bool micMuted: (Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio) 
                                     ? Pipewire.defaultAudioSource.audio.muted : false

    // Signals emitted on user hardware or external changes
    signal volumeUpdated(real newVolume, bool muted)
    signal micMuteUpdated(bool muted)

    // Ensure sink and source are tracked so their audio properties populate reactively
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    // Suppress notifications during initial startup
    property bool _initialized: false

    Timer {
        id: initTimer
        interval: 600
        running: true
        repeat: false
        onTriggered: {
            root._initialized = true;
        }
    }

    onVolumeChanged: {
        if (_initialized) {
            root.volumeUpdated(root.volume, root.isMuted);
        }
    }

    onIsMutedChanged: {
        if (_initialized) {
            root.volumeUpdated(root.volume, root.isMuted);
        }
    }

    onMicMutedChanged: {
        if (_initialized) {
            root.micMuteUpdated(root.micMuted);
        }
    }

    // Helper functions for programmatic adjustments
    function setVolume(val: real): void {
        if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
            Pipewire.defaultAudioSink.audio.volume = Math.max(0.0, Math.min(1.5, val));
        }
    }

    function toggleMute(): void {
        if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
        }
    }

    function toggleMicMute(): void {
        if (Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio) {
            Pipewire.defaultAudioSource.audio.muted = !Pipewire.defaultAudioSource.audio.muted;
        }
    }
}
