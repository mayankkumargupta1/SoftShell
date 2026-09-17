import QtQuick 2.15
import "../../theme"
import "../../components"
import "../../services"

Item {
    id: root

    property MediaService media: null

    implicitWidth: Theme.notchCollapsedWidth
    implicitHeight: Theme.notchCollapsedHeight

    Row {
        anchors.centerIn: parent
        width: Math.min(parent.width - 24, implicitWidth)
        spacing: 8

        // Left Mini Art Thumbnail
        Rectangle {
            id: miniArt
            width: 18
            height: 18
            radius: 5
            antialiasing: true
            color: Theme.surfaceBg
            anchors.verticalCenter: parent.verticalCenter
            clip: true

            Image {
                anchors.fill: parent
                source: root.media ? root.media.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.accentRed
                visible: miniArt.children[0].status !== Image.Ready
                Text {
                    anchors.centerIn: parent
                    text: "♫"
                    font.pixelSize: 10
                    color: "#ffffff"
                }
            }
        }

        // Center Track Title
        Text {
            id: titleText
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - miniArt.width - visualizer.width - 16
            text: root.media ? root.media.trackTitle : ""
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.bold: true
            color: Theme.textPrimary
            elide: Text.ElideRight
            renderType: Text.NativeRendering
        }

        // Right Mini Visualizer Waveform
        VisualizerBars {
            id: visualizer
            anchors.verticalCenter: parent.verticalCenter
            playing: root.media ? root.media.isPlaying : false
            barColor: Theme.accentRed
            maxBarHeight: 12
            minBarHeight: 2
            barWidth: 2
            spacing: 2
        }
    }
}
