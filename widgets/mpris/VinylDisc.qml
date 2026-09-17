import QtQuick 2.15
import QtQuick.Effects
import "../../theme"

Item {
    id: root

    property string artUrl: ""
    property bool isPlaying: false

    implicitWidth: 44
    implicitHeight: 44

    // Main rotating disc
    Item {
        id: disc
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        layer.samples: 4

        // Smooth continuous vinyl rotation
        NumberAnimation on rotation {
            from: 0
            to: 360
            duration: 18000
            loops: Animation.Infinite
            running: true
            paused: !root.isPlaying
        }

        // 1. Vinyl Base Disc (Black)
        Rectangle {
            id: discBase
            anchors.fill: parent
            radius: width / 2
            color: "#0f1016"
            border.color: Qt.rgba(1, 1, 1, 0.12)
            border.width: 1
            antialiasing: true
        }

        // 2. Masked Circular Album Art
        Item {
            id: artContainer
            anchors.fill: parent
            anchors.margins: 1

            Rectangle {
                id: artMask
                anchors.fill: parent
                radius: width / 2
                antialiasing: true
                visible: false
                layer.enabled: true
                layer.smooth: true
                layer.samples: 4
            }

            Image {
                id: albumArt
                anchors.fill: parent
                source: root.artUrl
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                visible: false
            }

            MultiEffect {
                anchors.fill: parent
                source: albumArt
                maskEnabled: true
                maskSource: artMask
                opacity: (albumArt.status === Image.Ready && root.artUrl.length > 0) ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation { duration: 350 }
                }
            }

            // Fallback Musical Icon if art is loading or unavailable
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                antialiasing: true
                color: "#1c1c24"
                visible: albumArt.status !== Image.Ready || root.artUrl.length === 0

                Text {
                    anchors.centerIn: parent
                    text: "♫"
                    font.pixelSize: parent.width * 0.35
                    color: Theme.clockColor
                }
            }
        }

        // 3. Subtle Concentric Vinyl Grooves
        Repeater {
            model: [0.90, 0.82, 0.74, 0.66, 0.58, 0.50]
            delegate: Rectangle {
                anchors.centerIn: parent
                width: disc.width * modelData
                height: width
                radius: width / 2
                color: "transparent"
                border.color: index % 2 === 0 ? "#ffffff" : "#000000"
                border.width: 1
                opacity: index % 2 === 0 ? 0.04 : 0.07
                antialiasing: true
            }
        }

        // 4. Center Spindle / Label Hub
        Rectangle {
            id: centerHub
            anchors.centerIn: parent
            width: parent.width * 0.28
            height: width
            radius: width / 2
            color: "#161720"
            border.color: Qt.rgba(1, 1, 1, 0.20)
            border.width: 1
            antialiasing: true

            // Spindle Hole
            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.40
                height: width
                radius: width / 2
                color: "#000000"
                border.color: Qt.rgba(0, 0, 0, 0.80)
                border.width: 1
                antialiasing: true
            }
        }
    }
}
