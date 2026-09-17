import QtQuick 2.15
import Quickshell
import Quickshell.Hyprland
import "../../theme"

// BarWorkspaceWidget — macOS Mission Control style workspace pill dots.
// Uses Hyprland.workspaces live model; clicking switches workspace.
Item {
    id: root

    implicitWidth: dotsRow.implicitWidth
    implicitHeight: Theme.barHeight

    Row {
        id: dotsRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Repeater {
            model: Hyprland.workspaces

            delegate: Item {
                id: dotItem
                required property var modelData
                readonly property bool isActive: modelData.focused

                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: 20
                implicitWidth: pill.width

                // Animated pill: wide when active, small dot when inactive
                Rectangle {
                    id: pill
                    anchors.verticalCenter: parent.verticalCenter
                    height: 6
                    width: isActive ? 18 : 6
                    radius: 3
                    antialiasing: true
                    color: isActive ? Theme.barText : (wsHover.hovered ? Qt.rgba(0, 0, 0, 0.55) : Qt.rgba(0, 0, 0, 0.28))

                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 150 } }

                    scale: wsTap.pressed ? 0.85 : (wsHover.hovered ? 1.15 : 1.0)
                    Behavior on scale { SpringAnimation { spring: 5; damping: 0.4; mass: 0.5 } }
                }

                HoverHandler {
                    id: wsHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    id: wsTap
                    gesturePolicy: TapHandler.ReleaseWithinBounds
                    onTapped: Hyprland.dispatch("workspace " + dotItem.modelData.id)
                }
            }
        }
    }
}
