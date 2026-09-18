import QtQuick 2.15
import "../../theme"
import "../../services"

Item {
    id: root

    property var media: null

    implicitWidth: contentRow.implicitWidth
    implicitHeight: 38

    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        // 1. Spinning Vinyl Disc with Album Art
        VinylDisc {
            anchors.verticalCenter: parent.verticalCenter
            width: 36
            height: 36
            artUrl: root.media ? root.media.trackArtUrl : ""
            isPlaying: root.media ? root.media.isPlaying : false
        }

        // 2. Track Title & Live Progress Timestamp
        Column {
            id: trackColumn
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(125, Math.max(75, Math.max(titleText.implicitWidth, progressText.implicitWidth)))
            spacing: 2

            // Track Title
            Text {
                id: titleText
                width: parent.width
                text: root.media ? root.media.trackTitle : "No Media"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                color: Theme.textPrimary
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            // Monospace Timestamp matching user's design: "00:26 / 27:43"
            Text {
                id: progressText
                text: root.media ? root.media.progressDisplayStr : "00:00 / 00:00"
                font.family: Theme.monoFontFamily
                font.pixelSize: 11
                font.weight: 500
                color: Theme.clockColor
                opacity: 0.9
                renderType: Text.NativeRendering
            }
        }

        // 3. SoftShell Glassmorphic Playback Control Buttons
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            // Previous Button
            MusicControlButton {
                iconText: "󰒮"
                iconPixelSize: 13
                iconOffsetX: 0
                onClicked: if (root.media) root.media.previous()
            }

            // Play / Pause Button
            MusicControlButton {
                readonly property bool playing: root.media && root.media.isPlaying
                iconText: playing ? "󰏤" : "󰐊"
                iconPixelSize: playing ? 14 : 15
                iconOffsetX: playing ? 0 : 1 // Optical horizontal centering for play triangle
                iconColor: playing ? Theme.accentGreen : "#ffffff"
                onClicked: if (root.media) root.media.togglePlaying()
            }

            // Next Button
            MusicControlButton {
                iconText: "󰒭"
                iconPixelSize: 13
                iconOffsetX: 0
                onClicked: if (root.media) root.media.next()
            }
        }
    }
}
