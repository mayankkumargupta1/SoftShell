import QtQuick 2.15
import "../../theme"
import "../../components"

// OsdCard — HUD overlay card displaying central icon and 16-segment level bar
Rectangle {
    id: root

    // "volume" | "mic" | "brightness"
    property string mode: "volume"
    property real value: 0.0          // 0.0 to 1.0
    property bool isMuted: false

    implicitWidth: 180
    implicitHeight: 180
    radius: 22

    // AMOLED black container without borders
    color: "#000000"
    border.width: 0
    antialiasing: true

    // Center icon representation
    readonly property string currentIcon: {
        if (mode === "volume") {
            if (isMuted || value <= 0.001) return "󰖁";
            if (value < 0.33) return "󰕿";
            if (value < 0.66) return "󰖀";
            return "󰕾";
        } else if (mode === "mic") {
            return isMuted ? "󰍭" : "󰍬";
        } else if (mode === "brightness") {
            return "󰖙";
        }
        return "󰕾";
    }

    // Center Icon / Graphic
    Item {
        id: iconContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 32
        width: 64
        height: 64

        // Font Icon for Volume and Mic
        Text {
            id: iconText
            anchors.centerIn: parent
            visible: root.mode !== "brightness"
            text: root.currentIcon
            font.family: Theme.iconFontFamily
            font.pixelSize: 56
            color: (root.mode === "mic" && root.isMuted) ? "#ff453a" : "#ffffff"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }

        // Custom Vector Radiant Sun (matches SoftShell reference image 3)
        Item {
            id: sunGraphic
            anchors.centerIn: parent
            width: 58
            height: 58
            visible: root.mode === "brightness"

            // Center hollow circle
            Rectangle {
                anchors.centerIn: parent
                width: 24
                height: 24
                radius: 12
                color: "transparent"
                border.color: "#ffffff"
                border.width: 3.2
                antialiasing: true
            }

            // 8 radial rays
            Repeater {
                model: 8
                Item {
                    anchors.centerIn: parent
                    width: 58
                    height: 58
                    rotation: index * 45

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        width: 3.2
                        height: 8.5
                        radius: 1.6
                        color: "#ffffff"
                        antialiasing: true
                    }
                }
            }
        }
    }

    // Bottom Level Indicator or Status Label
    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 26
        width: segmentedBar.implicitWidth
        height: 14

        // 16-segment horizontal tick bar
        OsdSegmentedBar {
            id: segmentedBar
            anchors.centerIn: parent
            value: root.value
            isMuted: root.isMuted
            visible: !(root.mode === "mic" && root.isMuted)
        }

        // Dedicated "Muted" indicator for microphone
        Text {
            anchors.centerIn: parent
            text: "Muted"
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: "#ff453a"
            visible: root.mode === "mic" && root.isMuted
            renderType: Text.NativeRendering
        }
    }
}
