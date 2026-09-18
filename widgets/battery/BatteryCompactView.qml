import QtQuick 2.15
import Quickshell
import "../../theme"
import "../../services"

// BatteryCompactView — The compact macOS Sonoma battery popover view
Item {
    id: root

    property PowerService powerService: null
    signal expandRequested()

    implicitWidth: 260
    implicitHeight: mainCol.implicitHeight

    Column {
        id: mainCol
        width: parent.width
        spacing: 8

        // -------------------------------------------------------------------
        // 1. Header: Battery Title, Percentage & Power Source Status
        // -------------------------------------------------------------------
        Column {
            width: parent.width
            spacing: 3

            Item {
                width: parent.width
                height: 18

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Battery"
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: "#ffffff"
                    renderType: Text.NativeRendering
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: (root.powerService ? root.powerService.percentage : 100) + "%"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Normal
                    color: Theme.textSecondary
                    renderType: Text.NativeRendering
                }
            }

            Text {
                text: {
                    if (!root.powerService) return "Power Source: Battery";
                    let isAC = root.powerService.isCharging || root.powerService.state === "fully-charged";
                    return "Power Source: " + (isAC ? "Power Adapter" : "Battery");
                }
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.textSecondary
                renderType: Text.NativeRendering
            }

            Text {
                text: {
                    if (!root.powerService) return "Calculating...";
                    if (root.powerService.state === "fully-charged") return "Fully Charged";
                    let time = root.powerService.timeRemaining;
                    if (time && time !== "Unknown" && time !== "Calculating...") {
                        if (root.powerService.isCharging) {
                            return "Charging (" + time + ")";
                        }
                        let formatted = time;
                        formatted = formatted.replace(/\bhours\b/gi, "Hours").replace(/\bminutes\b/gi, "Minutes");
                        if (!formatted.toLowerCase().includes("remaining")) {
                            formatted += " Remaining";
                        }
                        return formatted;
                    }
                    return root.powerService.isCharging ? "Charging" : "Calculating...";
                }
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.textSecondary
                renderType: Text.NativeRendering
            }
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.popoverSeparator
        }

        // -------------------------------------------------------------------
        // 2. Section: Apps Using Significant Energy (macOS Style)
        // -------------------------------------------------------------------
        SignificantEnergyList {
            width: parent.width
            significantApps: root.powerService ? root.powerService.significantApps : []
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.popoverSeparator
        }

        // -------------------------------------------------------------------
        // 3. Footer Action: Battery Settings... (Click to expand)
        // -------------------------------------------------------------------
        Item {
            width: parent.width
            height: 26

            Rectangle {
                id: settingsPill
                anchors.fill: parent
                radius: 5
                color: settingsHover.hovered ? Theme.barItemHover : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: "Battery Settings..."
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: "#ffffff"
                renderType: Text.NativeRendering
            }

            HoverHandler {
                id: settingsHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.expandRequested()
            }
        }
    }
}
