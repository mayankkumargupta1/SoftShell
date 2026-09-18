import QtQuick 2.15
import "../../theme"
import "../../services"

// BatteryExpandedView — Expanded Settings page matching user's Excalidraw design
Item {
    id: root

    property PowerService powerService: null
    signal collapseRequested()

    implicitWidth: 390
    implicitHeight: expandedCol.implicitHeight

    Column {
        id: expandedCol
        width: parent.width
        spacing: 12

        // -------------------------------------------------------------------
        // Navigation Header: "‹ Battery" back button
        // -------------------------------------------------------------------
        Item {
            width: parent.width
            height: 24

            Rectangle {
                id: backBtn
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: backRow.implicitWidth + 12
                height: 22
                radius: 4
                color: backHover.hovered ? Theme.barItemHover : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }

                Row {
                    id: backRow
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "‹"
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: "#0a84ff"
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: "Battery"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#0a84ff"
                        renderType: Text.NativeRendering
                    }
                }

                HoverHandler {
                    id: backHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.collapseRequested()
                }
            }
        }

        // -------------------------------------------------------------------
        // Section 1: Battery Health Pill Card
        // -------------------------------------------------------------------
        BatteryHealthHeader {
            width: parent.width
            powerService: root.powerService
        }

        // -------------------------------------------------------------------
        // Section 2: Energy Mode Card (Dual Profiles)
        // -------------------------------------------------------------------
        EnergyModeSection {
            width: parent.width
            powerService: root.powerService
        }

        // -------------------------------------------------------------------
        // Section 3: Battery Charge Status Timeline
        // -------------------------------------------------------------------
        BatteryTimelineView {
            width: parent.width
            powerService: root.powerService
        }
    }
}
