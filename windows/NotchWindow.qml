import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../components"
import "../services"
import "../widgets/clock"
import "../widgets/mpris"
import "../widgets/notifications"

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

    // Interaction state: expanded on hover or when clicked/pinned
    property bool isPinned: false
    // When notification banner is active, do NOT expand on hover; allow clicking notification buttons.
    // Only expand on click or pin. After notification is gone, behaves generally (expand on hover).
    readonly property bool isExpanded: isPinned || (!notifService.hasActiveBanner && hoverHandler.hovered)
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
                return Theme.notchNotificationCollapsedWidth;
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

        // Background Click Area (z: 0): clicks on empty space of the island expand/toggle it.
        // Clicks on interactive child buttons (inside contentLayer at z: 10) are consumed and do not expand the island.
        MouseArea {
            id: backgroundClickArea
            anchors.fill: parent
            z: 0
            cursorShape: Qt.PointingHandCursor
            onClicked: root.isPinned = !root.isPinned
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
                anchors.centerIn: parent
                visible: notifService.hasActiveBanner
            }

            // State A: Idle Collapsed (Time Centered)
            CompactClockWidget {
                timeService: timeService
                anchors.centerIn: parent
                visible: !notifService.hasActiveBanner && !root.isMusicActive
            }

            // State B: Music Collapsed (Time on Left, Music Info on Right, No Controls)
            Item {
                anchors.fill: parent
                visible: !notifService.hasActiveBanner && root.isMusicActive

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
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 56

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

                // Tier 2: Apple-Standard Paginated Notification Center
                ExpandedNotificationWidget {
                    notifService: notifService
                    anchors.top: tier1.bottom
                    anchors.topMargin: 6
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: root.islandFillet + 16
                    anchors.rightMargin: root.islandFillet + 16
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
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

                    // Right Side: Apple-Standard Music Player with Controls
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
