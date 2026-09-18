import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../theme"
import "../services"
import "../widgets/bar"

// BarWindow — SoftShell thin menu bar.
// Layer: Top (below Overlay, so the dynamic island floats above it).
// exclusiveZone: barHeight — pushes all desktop windows down by 28px.
PanelWindow {
    id: root

    // Anchor full width to the top edge
    anchors.top:    true
    anchors.left:   true
    anchors.right:  true
    anchors.bottom: false

    // Offset top margin by -1 to eliminate any top display border
    margins.top: -1

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

    // Wallpaper management service (ensures active wallpaper is maintained)
    WallpaperService {
        id: wallpaperService
    }

    // --- Bar Background (Pure borderless modern SoftShell translucent glass) ---
    Rectangle {
        id: barBg
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.barBgTop }
            GradientStop { position: 1.0; color: Theme.barBgBottom }
        }
    }

    // --- Content: Left (App Menu) | Center gap (Dynamic Island) | Right (Status Icons) ---
    Item {
        anchors.fill: parent
        anchors.leftMargin:  20
        anchors.rightMargin: 20

        // LEFT: SoftShell logo | App Name | File | Edit | View | Go | Tools | Window | Help
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
