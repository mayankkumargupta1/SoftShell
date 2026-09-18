import QtQuick 2.15
import Quickshell
import "../../theme"
import "../../services"
import "../battery"

// BarStatusIcons — Apple macOS right-side menu bar items:
// 1. Battery | 2. Wi-Fi | 3. Control Center
Item {
    id: root

    property SystemStatsService stats: null

    implicitHeight: Theme.barHeight
    implicitWidth: iconsRow.implicitWidth

    Row {
        id: iconsRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        // 1. Battery Icon (Dynamic colors: <40% yellow, <20% red, charging green)
        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            height: 22

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: (batTap.pressed || batHover.hovered) ? Theme.barItemHover : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            BatteryIcon {
                anchors.centerIn: parent
                percentage: (root.stats && root.stats.batteryPercent > 0) ? root.stats.batteryPercent : 100
                isCharging: root.stats ? root.stats.isCharging : false
            }

            HoverHandler {
                id: batHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                id: batTap
                onTapped: {
                    Quickshell.execDetached(["quickshell", "ipc", "call", "battery", "toggle"]);
                }
            }
        }

        // 2. Wi-Fi Icon
        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 22

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: wifiHover.hovered ? Theme.barItemHover : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            Text {
                anchors.centerIn: parent
                text: "󰤨"
                font.family: Theme.iconFontFamily
                font.pixelSize: 15
                color: Theme.barText
                renderType: Text.NativeRendering
                style: Text.Raised
                styleColor: Qt.rgba(0, 0, 0, 0.40)
            }

            HoverHandler {
                id: wifiHover
                cursorShape: Qt.PointingHandCursor
            }
        }

        // 3. Control Center Icon (macOS 2-toggle sliders)
        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 20

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: ccHover.hovered ? Theme.barItemHover : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            // Apple macOS Control Center Capsule Toggles (matching SF Symbol switch.2)
            Item {
                anchors.centerIn: parent
                width: 16
                height: 14.5

                // Top Switch: capsule outline with white circular knob on left
                Item {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 6.5

                    Rectangle {
                        id: topCapsule
                        anchors.fill: parent
                        radius: 3.25
                        color: "transparent"
                        border.color: Theme.barText
                        border.width: 1.1
                        antialiasing: true

                        // Circular knob on left
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 1.8
                            width: 3.3
                            height: 3.3
                            radius: 1.65
                            color: Theme.barText
                            antialiasing: true
                        }
                    }
                }

                // Bottom Switch: capsule outline with solid white left fill (active toggle)
                Item {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 6.5

                    Rectangle {
                        id: bottomCapsule
                        anchors.fill: parent
                        radius: 3.25
                        color: "transparent"
                        border.color: Theme.barText
                        border.width: 1.1
                        antialiasing: true

                        // Left solid fill
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 9.5
                            radius: 3.25
                            color: Theme.barText
                            antialiasing: true
                        }
                    }
                }
            }

            HoverHandler {
                id: ccHover
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
