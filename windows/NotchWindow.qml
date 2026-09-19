import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"
import "../components"
import "../services"
import "../widgets/clock"
import "../widgets/mpris"
import "../widgets/notifications"
import "../widgets/clipboard"

PanelWindow {
    id: root

    // Top screen edge anchoring
    anchors {
        top: true
        bottom: false
        left: false
        right: false
    }

    // 0 means it floats over windows without reserving desktop space
    exclusiveZone: 0

    // Transparent window surface
    color: "transparent"

    // Wayland namespace for compositor window rules
    WlrLayershell.namespace: "quickshell:notch"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    // Reactive time and date service
    TimeService {
        id: timeService
    }

    // Reactive MPRIS music service
    MediaService {
        id: mediaService
    }

    // Reactive notification service
    NotificationService {
        id: notifService
    }

    // Reactive clipboard response service
    ClipboardService {
        id: clipboardService
    }

    // Interaction state: expanded when clicked/pinned (hover never pins, it just peeks)
    property bool isPinned: false

    IpcHandler {
        target: "notch"
        function toggle(): void { root.isPinned = !root.isPinned; }
        function expand(): void { root.isPinned = true; }
        function collapse(): void { root.isPinned = false; }
    }

    // Auto-reset isPinned when nothing is left to show in expanded state
    // (notification cleared or island dismissed via close button)
    Connections {
        target: notifService
        function onHasActiveBannerChanged() {
            if (notifService.hasActiveBanner) {
                // New banner: block hover expansion
                root.suppressHoverExpand = true;
            } else {
                // Banner gone: if nothing is pinned to show, unpin
                if (!notifService.hasNotifications) {
                    root.isPinned = false;
                }
            }
        }
        function onHasNotificationsChanged() {
            // All notifications cleared from expanded center: collapse
            if (!notifService.hasNotifications && !notifService.hasActiveBanner) {
                root.isPinned = false;
            }
        }
        function onWindowFocused() {
            // Collapse island so user has full view of the newly focused workspace/window
            root.isPinned = false;
            autoCollapseTimer.stop();
        }
    }

    // Suppress hover expansion whenever a notification is active in shrink mode,
    // or until the cursor leaves the island after a notification is dismissed/finished.
    property bool suppressHoverExpand: notifService.hasActiveBanner

    Connections {
        target: hoverHandler
        function onHoveredChanged() {
            // Forward hover state to pause/resume auto-dismiss timer
            notifService.isIslandHovered = hoverHandler.hovered;

            // Only clear suppression after mouse has left the island and no banner is active
            if (!hoverHandler.hovered && !notifService.hasActiveBanner) {
                root.suppressHoverExpand = false;
            }
        }
    }

    // Auto-collapse timer: fires after user taps "View" to read notification
    // Gives 6 seconds to read, then collapses unless still hovered.
    Timer {
        id: autoCollapseTimer
        interval: 6000
        repeat: false
        running: false
        onTriggered: {
            if (!hoverHandler.hovered) {
                root.isPinned = false;
            }
        }
    }

    // When notification is there in shrink mode, hover does NOT expand;
    // only clicking empty space (or pin) expands.
    readonly property bool isExpanded: isPinned || (!root.suppressHoverExpand && hoverHandler.hovered)
    readonly property bool isMusicActive: mediaService.isMediaActive

    // --- Dynamic Multi-State Island Geometry ---
    readonly property real targetWidth: {
        if (isExpanded) {
            if (notifService.hasNotifications) {
                return Theme.notchExpandedWithNotifsWidth;
            } else if (isMusicActive) {
                return Theme.notchMusicExpandedWidth;
            } else {
                return Theme.notchExpandedWidth;
            }
        } else {
            if (notifService.hasActiveBanner) {
                return Theme.notchNotificationCollapsedWidth + (notifService.bannerQueueCount > 0 ? 38 : 0);
            } else if (clipboardService.hasActiveCopy) {
                return Theme.notchClipboardWidth;
            } else if (isMusicActive) {
                return Theme.notchMusicCollapsedWidth;
            } else {
                return Theme.notchCollapsedWidth;
            }
        }
    }

    readonly property real targetHeight: {
        if (isExpanded) {
            if (notifService.hasNotifications) {
                return Theme.notchExpandedWithNotifsHeight;
            } else if (isMusicActive) {
                return Theme.notchMusicExpandedHeight;
            } else {
                return Theme.notchExpandedHeight;
            }
        } else {
            if (notifService.hasActiveBanner) {
                return Theme.notchNotificationCollapsedHeight;
            } else {
                return Theme.notchCollapsedHeight;
            }
        }
    }

    readonly property real targetFillet: isExpanded ? Theme.expandedFillet : (notifService.hasActiveBanner ? 16.0 : Theme.collapsedFillet)
    readonly property real targetRadius: isExpanded ? Theme.expandedRadius : (notifService.hasActiveBanner ? 22.0 : Theme.collapsedRadius)

    property real islandWidth: targetWidth
    property real islandHeight: targetHeight
    property real islandFillet: targetFillet
    property real islandRadius: targetRadius

    Behavior on islandWidth {
        NumberAnimation {
            duration: root.isExpanded ? 280 : 240
            easing.type: Easing.OutCubic
        }
    }

    Behavior on islandHeight {
        NumberAnimation {
            duration: root.isExpanded ? 280 : 240
            easing.type: Easing.OutCubic
        }
    }

    Behavior on islandFillet {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Behavior on islandRadius {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    // Unified animation progress for cross-fade transitions
    property real animProgress: isExpanded ? 1.0 : 0.0

    Behavior on animProgress {
        NumberAnimation {
            duration: root.isExpanded ? 280 : 220
            easing.type: Easing.OutCubic
        }
    }

    // Generous pre-allocated window surface: prevents Wayland buffer reallocation clipping across all states
    readonly property real shadowMargin: 16
    implicitWidth: 720
    implicitHeight: 400

    // Restrict Wayland compositor input events strictly to the active dynamic island
    mask: Region {
        item: islandContainer
    }

    // Subtle, tight contour shadow to smooth edges and transition seamlessly into background
    MultiEffect {
        id: islandShadow
        source: islandShape
        anchors.fill: islandContainer
        shadowEnabled: true
        shadowColor: "#000000"
        shadowOpacity: 0.35
        shadowBlur: 0.20
        shadowVerticalOffset: 1
        layer.smooth: true
        z: -1
    }

    // Master Dynamic Island Interactive Container
    Item {
        id: islandContainer
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.islandWidth
        height: root.islandHeight

        // Master Hover Handler: covers BOTH background and all child widgets
        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
        }

        // Background Click Area (z: 0): clicks on empty space toggle expand/collapse.
        // Child buttons in contentLayer (z: 10) use their own TapHandler/MouseArea with
        // propagateComposedEvents: false so clicks don't bubble through to here.
        MouseArea {
            id: backgroundClickArea
            anchors.fill: parent
            z: 0
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.isPinned = !root.isPinned;
                // Cancel any pending auto-collapse since user explicitly toggled
                autoCollapseTimer.stop();
            }
        }

        // 1. The Dynamic Island Background Shape
        IslandShape {
            id: islandShape
            anchors.fill: parent
            fillet: root.islandFillet
            radius: root.islandRadius
            fillColor: Theme.islandBg
        }

        // 2. Foreground Interactive Content Layer (Always on top)
        Item {
            id: contentLayer
            anchors.fill: parent
            z: 10

        // 1. COLLAPSED VIEW (Height 36px)
        Item {
            id: collapsedContainer
            anchors.fill: parent
            opacity: Math.max(0.0, 1.0 - (root.animProgress * 2.5))
            visible: opacity > 0.01

            // State N: Active Notification Banner (Priority 1)
            CompactNotificationBanner {
                id: notifBanner
                notifService: notifService
                anchors.fill: parent
                visible: notifService.hasActiveBanner
                onViewClicked: {
                    // Collapse island so user can interact directly with the focused app
                    root.isPinned = false;
                    autoCollapseTimer.stop();
                }
            }

            // State C: Active Clipboard Copy Response (Priority 2)
            CompactClipboardWidget {
                id: clipboardWidget
                clipboardService: clipboardService
                anchors.centerIn: parent
                visible: !notifService.hasActiveBanner && clipboardService.hasActiveCopy
            }

            // State A: Idle Collapsed (Time Centered)
            CompactClockWidget {
                timeService: timeService
                anchors.centerIn: parent
                visible: !notifService.hasActiveBanner && !clipboardService.hasActiveCopy && !root.isMusicActive
            }

            // State B: Music Collapsed (Time on Left, Music Info on Right, No Controls)
            Item {
                anchors.fill: parent
                visible: !notifService.hasActiveBanner && !clipboardService.hasActiveCopy && root.isMusicActive

                CompactClockWidget {
                    timeService: timeService
                    anchors.left: parent.left
                    anchors.leftMargin: root.islandFillet + 14
                    anchors.verticalCenter: parent.verticalCenter
                }

                CompactMusicWidget {
                    media: mediaService
                    anchors.right: parent.right
                    anchors.rightMargin: root.islandFillet + 14
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // 2. EXPANDED VIEW (On Hover/Pin)
        Item {
            id: expandedContainer
            anchors.fill: parent
            opacity: Math.max(0.0, (root.animProgress - 0.3) / 0.7)
            visible: opacity > 0.01

            // Layout 1: 2-Tier Stack with Notification Center (When notifications exist)
            Item {
                anchors.fill: parent
                visible: notifService.hasNotifications

                // Tier 1: Top Status Bar (Clock on Left, Music Player on Right only when active)
                Item {
                    id: tier1
                    anchors.top: parent.top
                    anchors.topMargin: 18
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 54

                    ClockWidget {
                        timeService: timeService
                        alignLeft: root.isMusicActive
                        anchors.left: root.isMusicActive ? parent.left : undefined
                        anchors.leftMargin: root.isMusicActive ? (root.islandFillet + 24) : 0
                        anchors.horizontalCenter: root.isMusicActive ? undefined : parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ExpandedMusicWidget {
                        media: mediaService
                        visible: root.isMusicActive
                        anchors.right: parent.right
                        anchors.rightMargin: root.islandFillet + 24
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Tier 2: SoftShell Paginated Notification Center
                ExpandedNotificationWidget {
                    notifService: notifService
                    anchors.top: tier1.bottom
                    anchors.topMargin: 20
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: root.islandFillet + 16
                    anchors.rightMargin: root.islandFillet + 16
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 14
                }
            }

            // Layout 2: Single-Tier Views (When NO notifications exist)
            Item {
                anchors.fill: parent
                visible: !notifService.hasNotifications

                // State C: Idle Expanded (Full Date & Time Centered)
                ClockWidget {
                    timeService: timeService
                    alignLeft: false
                    anchors.centerIn: parent
                    visible: !root.isMusicActive
                }

                // State D: Music Expanded (Date & Time Shifted Left, Music Player with Controls on Right)
                Item {
                    anchors.fill: parent
                    visible: root.isMusicActive

                    // Left Side: Date & Time strictly left-aligned (matching user reference)
                    ClockWidget {
                        timeService: timeService
                        alignLeft: true
                        anchors.left: parent.left
                        anchors.leftMargin: root.islandFillet + 18
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Right Side: SoftShell Music Player with Controls
                    ExpandedMusicWidget {
                        media: mediaService
                        anchors.right: parent.right
                        anchors.rightMargin: root.islandFillet + 18
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
}
