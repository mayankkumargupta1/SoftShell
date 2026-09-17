import QtQuick 2.15
import "../../theme"
import "../../components"
import "../../services"

Item {
    id: root

    property var media: null

    implicitHeight: 28
    implicitWidth: contentRow.implicitWidth

    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Mini spinning vinyl disc
        VinylDisc {
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            artUrl: root.media ? root.media.trackArtUrl : ""
            isPlaying: root.media ? root.media.isPlaying : false
        }

        // Track Title
        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(130, implicitWidth)
            text: root.media ? root.media.trackTitle : ""
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
            color: Theme.textPrimary
            elide: Text.ElideRight
            renderType: Text.NativeRendering
        }

        // Audio waveform bars
        VisualizerBars {
            anchors.verticalCenter: parent.verticalCenter
            playing: root.media ? root.media.isPlaying : false
            barColor: Theme.accentGreen
            barWidth: 2
            maxBarHeight: 12
            minBarHeight: 2
            spacing: 2
        }
    }
}
