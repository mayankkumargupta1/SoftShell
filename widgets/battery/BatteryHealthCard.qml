import QtQuick 2.15
import "../../theme"
import "../../services"

// BatteryHealthCard — Detailed SoftShell Battery Health & Diagnostics Card
Rectangle {
    id: root

    property PowerService powerService: null

    width: parent ? parent.width : 280
    height: contentCol.implicitHeight + 20
    radius: 10
    color: Theme.popoverCardBg
    border.color: Theme.popoverBorder
    border.width: 1

    Column {
        id: contentCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 8

        // 1. Header: Battery Health & Condition Badge
        Item {
            width: parent.width
            height: 20

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰂄"
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 13
                    color: Theme.batteryCharging
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Battery Health"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: Theme.textPrimary
                }
            }

            // SoftShell Condition Badge ("Normal")
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: conditionText.implicitWidth + 12
                height: 18
                radius: 9
                color: Qt.rgba(48, 209, 88, 0.20)
                border.color: Qt.rgba(48, 209, 88, 0.40)
                border.width: 1

                Text {
                    id: conditionText
                    anchors.centerIn: parent
                    text: "Normal"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    color: "#30d158"
                }
            }
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.popoverSeparator
        }

        // 2. Metrics Grid
        Grid {
            width: parent.width
            columns: 2
            rowSpacing: 6
            columnSpacing: 10

            // Row A: Maximum Capacity (Health %)
            Text {
                width: 130
                text: "Maximum Capacity"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.textSecondary
            }
            Text {
                text: (root.powerService ? root.powerService.health.toFixed(1) : "97.1") + "%"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: Theme.textPrimary
            }

            // Row B: Cycle Count
            Text {
                width: 130
                text: "Cycle Count"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.textSecondary
            }
            Text {
                text: root.powerService ? root.powerService.cycles.toString() : "325"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: Theme.textPrimary
            }

            // Row C: Live Power Draw (Watts)
            Text {
                width: 130
                text: "Power Draw"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.textSecondary
            }
            Text {
                text: (root.powerService && root.powerService.energyRate > 0)
                      ? (root.powerService.energyRate.toFixed(2) + " W")
                      : "Idle"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: (root.powerService && root.powerService.energyRate > 15) ? Theme.statYellow : Theme.textPrimary
            }

            // Row D: Full Charge Capacity
            Text {
                width: 130
                text: "Full Capacity"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.textSecondary
            }
            Text {
                text: (root.powerService ? root.powerService.energyFull.toFixed(1) : "58.3") + " / " +
                      (root.powerService ? root.powerService.energyDesign.toFixed(0) : "60") + " Wh"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: Theme.textPrimary
            }
        }
    }
}
