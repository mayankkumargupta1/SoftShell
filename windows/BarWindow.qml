import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../theme"
import "../services"
import "../widgets/bar"

// BarWindow — macOS-style thin white menu bar.
// Layer: Top (below Overlay, so the dynamic island floats above it).
// exclusiveZone: barHeight — pushes all desktop windows down by 28px.
PanelWindow {
    id: root

    // Anchor full width to the top edge
    anchors.top:    true
    anchors.left:   true
    anchors.right:  true
    anchors.bottom: false

    implicitHeight: Theme.barHeight

    // Push windows down so they start below the bar
    exclusiveZone: Theme.barHeight

    color: "transparent"

    WlrLayershell.layer:     WlrLayer.Top
    WlrLayershell.namespace: "quickshell:bar"

    // System stats service (shared instance for all widgets)
    SystemStatsService {
        id: statsService
    }

    // --- Bar Background ---
    Rectangle {
        id: barBg
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.barBgTop }
            GradientStop { position: 1.0; color: Theme.barBgBottom }
        }

        // Hairline top highlight — subtle Apple glass specular edge
        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.top:    parent.top
            height: 1
            color: Theme.barHighlight
        }

        // Hairline bottom border — macOS menu bar separator
        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.barBorder
        }
    }

    // --- Content: Left (App Menu) | Center gap (Dynamic Island) | Right (Status Icons) ---
    Item {
        anchors.fill: parent
        anchors.leftMargin:  16
        anchors.rightMargin: 16

        // LEFT: Apple logo | App Name | File | Edit | View | Go | Tools | Window | Help
        BarAppMenu {
            id: appMenu
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        // CENTER: Empty space reserved for the dynamic island.
        // The island lives on WlrLayer.Overlay and renders on top of this bar.
        // We leave Theme.barIslandGap px of safe dead space in the center.
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width: Theme.barIslandGap
        }

        // RIGHT: Battery | Wi-Fi | Control Center
        BarStatusIcons {
            id: statusIcons
            stats: statsService
            anchors.right:          parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
