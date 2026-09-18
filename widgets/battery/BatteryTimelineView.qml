import QtQuick 2.15
import "../../theme"
import "../../services"

// BatteryTimelineView — Section 3: Battery charge status over time (StatusBar timeline)
Item {
    id: root

    property PowerService powerService: null

    implicitWidth: parent ? parent.width : 380
    implicitHeight: col.implicitHeight

    property var activeHoverData: null
    property real tooltipX: 0

    Column {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 6

        // Title
        Text {
            text: "Battery charge status"
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: "#ffffff"
            renderType: Text.NativeRendering
        }

        // Timeline Recessed Container Box
        Rectangle {
            id: box
            width: parent.width
            height: 48
            radius: 8
            color: "#0e0e10"
            border.color: Theme.popoverBorder
            border.width: 1
            clip: false

            Timer {
                id: hideTimer
                interval: 80
                repeat: false
                onTriggered: {
                    root.activeHoverData = null;
                }
            }

            HoverHandler {
                id: boxHover
                onHoveredChanged: {
                    if (!hovered) {
                        hideTimer.stop();
                        root.activeHoverData = null;
                    }
                }
            }

            // Row of Capsules
            Row {
                id: capsulesRow
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: (root.powerService && root.powerService.batteryHistory && root.powerService.batteryHistory.length > 0)
                           ? root.powerService.batteryHistory : []

                    BatteryTimelineItem {
                        itemData: modelData
                        onHovered: (data, xPos) => {
                            hideTimer.stop();
                            root.activeHoverData = data;
                            root.tooltipX = capsulesRow.x + xPos;
                        }
                        onUnhovered: {
                            hideTimer.restart();
                        }
                    }
                }
            }

            // Floating Tooltip above the hovered capsule
            BatteryTimelineTooltip {
                id: tooltip
                visible: root.activeHoverData !== null
                z: 200
                itemData: root.activeHoverData
                anchors.bottom: box.top
                anchors.bottomMargin: 6
                x: Math.max(6, Math.min(box.width - width - 6, root.tooltipX - width / 2))
            }
        }
    }
}
