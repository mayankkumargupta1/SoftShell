import QtQuick 2.15
import "../../theme"
import "../../components"
import "../../services"

Item {
    id: root

    property MediaService media: null

    implicitWidth: Theme.notchExpandedWidth
    implicitHeight: Theme.notchExpandedHeight

    // Top utility bar (indicators and settings icon)
    Item {
        id: topBar
        anchors.top: parent.top
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        height: 18

        // Left indicators (e.g. screen share / lock indicator like SoftShell)
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Text {
                text: "􀊝" // SF icon or fallback symbol
                font.pixelSize: 11
                color: Theme.textSecondary
                visible: false
            }

            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: Theme.accentGreen
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Active"
                font.pixelSize: 10
                font.family: Theme.fontFamily
                color: Theme.textTertiary
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Right quick-action buttons
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            StyledButton {
                width: 20
                height: 20
                iconSize: 12
                iconText: "⚙"
                iconColor: Theme.textSecondary
                hoverBgColor: Theme.surfaceHover
            }
        }
    }

    // Main media card layout
    Row {
        id: mainRow
        anchors.top: topBar.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 22
        anchors.right: parent.right
        anchors.rightMargin: 22
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        spacing: 16

        // 1. Album Artwork Container
        Item {
            id: albumArtWrapper
            width: 78
            height: 78
            anchors.verticalCenter: parent.verticalCenter

            // Artwork shadow
            Rectangle {
                anchors.fill: parent
                radius: 14
                antialiasing: true
                color: "#000000"
                opacity: 0.4
                anchors.topMargin: 2
            }

            // Clipped Album Art Image
            Rectangle {
                id: imageMask
                anchors.fill: parent
                radius: 14
                antialiasing: true
                color: Theme.surfaceBg
                clip: true

                Image {
                    id: albumImage
                    anchors.fill: parent
                    source: root.media ? root.media.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true

                    // Placeholder if no image or loading
                    Rectangle {
                        anchors.fill: parent
                        color: Theme.surfaceHover
                        visible: albumImage.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: "🎵"
                            font.pixelSize: 28
                        }
                    }
                }
            }

            // Mini Music Red Badge at bottom-right corner
            Rectangle {
                id: musicBadge
                width: 20
                height: 20
                radius: 6
                antialiasing: true
                color: Theme.accentRed
                anchors.right: parent.right
                anchors.rightMargin: -4
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -4
                border.color: Theme.islandBg
                border.width: 1.5

                Text {
                    anchors.centerIn: parent
                    text: "♫"
                    font.pixelSize: 11
                    color: "#ffffff"
                    font.bold: true
                }
            }
        }

        // 2. Center details & playback controls
        Column {
            id: detailsCol
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - albumArtWrapper.width - rightActions.width - (parent.spacing * 2)
            spacing: 3

            // Track Title
            Text {
                width: parent.width
                text: root.media ? root.media.trackTitle : ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textPrimary
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            // Album / Artist Info
            Text {
                width: parent.width
                text: {
                    if (!root.media) return "";
                    if (root.media.trackAlbum !== "") {
                        return root.media.trackArtist + " — " + root.media.trackAlbum;
                    }
                    return root.media.trackArtist;
                }
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            Item { width: 1; height: 3 } // Spacer

            // Controls Row (Prev, Play/Pause, Next)
            Row {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                StyledButton {
                    width: 28
                    height: 28
                    iconSize: 13
                    iconText: "⏮"
                    iconColor: Theme.textPrimary
                    onClicked: if (root.media) root.media.previous()
                }

                StyledButton {
                    width: 32
                    height: 32
                    iconSize: 16
                    iconText: root.media && root.media.isPlaying ? "⏸" : "▶"
                    iconColor: Theme.textPrimary
                    bgColor: Theme.surfaceHover
                    onClicked: if (root.media) root.media.togglePlaying()
                }

                StyledButton {
                    width: 28
                    height: 28
                    iconSize: 13
                    iconText: "⏭"
                    iconColor: Theme.textPrimary
                    onClicked: if (root.media) root.media.next()
                }
            }

            // Timeline Scrubber with Time Display
            Row {
                width: parent.width
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: root.media ? root.media.formatTime(root.media.position) : "0:00"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.textTertiary
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                }

                SmoothSlider {
                    width: parent.width - 66
                    anchors.verticalCenter: parent.verticalCenter
                    value: root.media ? root.media.progress : 0.0
                    onSeekRequested: function(frac) {
                        if (root.media) root.media.seekFraction(frac);
                    }
                }

                Text {
                    text: {
                        if (!root.media) return "0:00";
                        let remaining = Math.max(0, root.media.length - root.media.position);
                        return "-" + root.media.formatTime(remaining);
                    }
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.textTertiary
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                }
            }
        }

        // 3. Right side secondary panel (Mirror / Output device / Visualizer)
        Column {
            id: rightActions
            width: 58
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            horizontalAlignment: Text.AlignHCenter

            // Action button (Mirror / Camera / AirPlay style)
            Rectangle {
                width: 44
                height: 44
                radius: 22
                antialiasing: true
                color: Theme.surfaceBg
                anchors.horizontalCenter: parent.horizontalCenter

                HoverHandler { id: mirrorHover; cursorShape: Qt.PointingHandCursor }

                scale: mirrorHover.hovered ? 1.06 : 1.0
                Behavior on scale { NumberAnimation { duration: Theme.animFast } }

                Column {
                    anchors.centerIn: parent
                    spacing: 1

                    Text {
                        text: "◎"
                        font.pixelSize: 16
                        color: Theme.textPrimary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Mirror"
                        font.family: Theme.fontFamily
                        font.pixelSize: 8
                        color: Theme.textSecondary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // Mini visualizer beneath action button
            VisualizerBars {
                anchors.horizontalCenter: parent.horizontalCenter
                playing: root.media ? root.media.isPlaying : false
                barColor: Theme.accentRed
            }
        }
    }
}
