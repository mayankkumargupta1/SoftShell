import QtQuick 2.15
import Quickshell
import Quickshell.Services.Mpris

Item {
    id: root

    // Find the active or playing player
    readonly property var playersList: Mpris.players ? Mpris.players.values : []
    readonly property var activePlayer: {
        // 1. Priority: actively playing player
        for (let i = 0; i < playersList.length; i++) {
            let p = playersList[i];
            if (p && p.isPlaying) return p;
        }
        // 2. Priority: paused player with a track queued (not stopped, has real track metadata)
        for (let i = 0; i < playersList.length; i++) {
            let p = playersList[i];
            if (p && (p.playbackState === MprisPlaybackState.Paused || p.playbackState === 2)) {
                let hasTitle = p.trackTitle && p.trackTitle.trim().length > 0 && p.trackTitle !== "Unknown Track";
                let hasDuration = p.length > 1.0;
                if (hasTitle || hasDuration) {
                    return p;
                }
            }
        }
        return null;
    }

    readonly property bool hasRealPlayer: activePlayer !== null
    readonly property bool isMediaActive: hasRealPlayer && (activePlayer.isPlaying || activePlayer.playbackState === MprisPlaybackState.Paused || activePlayer.playbackState === 2)
    readonly property bool isPlaying: hasRealPlayer ? activePlayer.isPlaying : false

    // Track Metadata
    readonly property string trackTitle: hasRealPlayer ? (activePlayer.trackTitle || "Unknown Track") : ""
    readonly property string trackArtist: hasRealPlayer ? (activePlayer.trackArtist || "Unknown Artist") : ""
    readonly property string trackAlbum: hasRealPlayer ? (activePlayer.trackAlbum || "") : ""
    readonly property string trackArtUrl: {
        if (!hasRealPlayer || !activePlayer.trackArtUrl) return "";
        let url = activePlayer.trackArtUrl;
        if (url.startsWith("file://") || url.startsWith("http://") || url.startsWith("https://")) {
            return url;
        }
        return "file://" + url;
    }

    // Geometry & Duration
    readonly property real length: hasRealPlayer ? (activePlayer.length > 0 ? activePlayer.length : 1.0) : 1.0
    property real livePosition: hasRealPlayer ? activePlayer.position : 0.0

    readonly property real progress: length > 0 ? Math.max(0.0, Math.min(1.0, livePosition / length)) : 0.0
    readonly property string positionStr: formatTime(livePosition)
    readonly property string lengthStr: formatTime(length)
    readonly property string progressDisplayStr: positionStr + " / " + lengthStr

    // Sync livePosition with player position updates
    Connections {
        target: root.activePlayer
        function onPositionChanged() {
            if (root.activePlayer) {
                root.livePosition = root.activePlayer.position;
            }
        }
    }

    // Interpolation ticker while playing (since MPRIS only broadcasts position on events)
    Timer {
        id: positionTicker
        interval: 500
        running: root.isPlaying
        repeat: true
        onTriggered: {
            if (root.livePosition + 0.5 <= root.length) {
                root.livePosition += 0.5;
            }
        }
    }

    // Playback Controls
    function togglePlaying() {
        if (hasRealPlayer && activePlayer.canTogglePlaying) {
            activePlayer.togglePlaying();
        } else if (hasRealPlayer && activePlayer.canPlay && !isPlaying) {
            activePlayer.play();
        } else if (hasRealPlayer && activePlayer.canPause && isPlaying) {
            activePlayer.pause();
        }
    }

    function next() {
        if (hasRealPlayer && activePlayer.canGoNext) {
            activePlayer.next();
        }
    }

    function previous() {
        if (hasRealPlayer && activePlayer.canGoPrevious) {
            activePlayer.previous();
        }
    }

    function seekFraction(fraction) {
        if (hasRealPlayer && activePlayer.canSeek) {
            let targetSec = fraction * length;
            let delta = targetSec - livePosition;
            activePlayer.seek(delta);
            livePosition = targetSec;
        }
    }

    function formatTime(totalSeconds) {
        if (!totalSeconds || isNaN(totalSeconds) || totalSeconds < 0) return "00:00";
        let sec = Math.floor(totalSeconds);
        let m = Math.floor(sec / 60);
        let s = sec % 60;
        let mStr = m < 10 ? "0" + m : "" + m;
        let sStr = s < 10 ? "0" + s : "" + s;
        return mStr + ":" + sStr;
    }
}
