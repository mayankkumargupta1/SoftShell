pragma Singleton
import QtQuick 2.15

QtObject {
    // --- Colors ---
    // Pure AMOLED Black
    readonly property color islandBg: "#000000"
    readonly property color surfaceBg: "#121214"
    readonly property color surfaceHover: "#222226"
    readonly property color surfaceActive: "#303036"

    // Typography Colors
    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: "#98989f"
    readonly property color textTertiary: "#636366"

    // Accent & Widget Colors
    readonly property color accentRed: "#ff375f"
    readonly property color accentBlue: "#0a84ff"
    readonly property color accentGreen: "#30d158"
    readonly property color clockColor: "#b6d8ff"

    // --- Geometry & Radii ---
    readonly property int notchCollapsedWidth: 200
    readonly property int notchCollapsedHeight: 36
    readonly property int notchExpandedWidth: 440
    readonly property int notchExpandedHeight: 130

    // Music Active Geometry
    readonly property int notchMusicCollapsedWidth: 340
    readonly property int notchMusicExpandedWidth: 560
    readonly property int notchMusicExpandedHeight: 60

    // Clipboard Response Geometry
    readonly property int notchClipboardWidth: 290

    // Notification Geometry & Timing (macOS Big Sur & iOS Standard)
    readonly property int notchNotificationCollapsedWidth: 480
    readonly property int notchNotificationCollapsedHeight: 52
    readonly property int notchExpandedWithNotifsWidth: 600
    readonly property int notchExpandedWithNotifsHeight: 360
    readonly property int notifSingleDuration: 7000
    readonly property int notifQueuedDuration: 4000

    // macOS Frosted Glass & Notification Tokens
    readonly property color cardBg: Qt.rgba(255, 255, 255, 0.08)
    readonly property color cardHover: Qt.rgba(255, 255, 255, 0.13)
    readonly property color cardBorder: Qt.rgba(255, 255, 255, 0.12)
    readonly property color cardBorderPinned: Qt.rgba(245, 166, 35, 0.45)
    readonly property color pinActive: "#f5a623"
    readonly property color appleSubtext: "#98989f"
    readonly property color appleHeaderMuted: "#8e8e93"
    readonly property int cardRadius: 14

    // Radii in collapsed and expanded states
    readonly property real collapsedFillet: 12.0
    readonly property real collapsedRadius: 18.0
    readonly property real expandedFillet: 18.0
    readonly property real expandedRadius: 26.0

    // --- Animation Specs ---
    readonly property int animExpandDuration: 280
    readonly property int animCollapseDuration: 220

    // --- Typography Metrics ---
    readonly property string fontFamily: "SF Pro Display, Inter, Noto Sans, sans-serif"
    readonly property string monoFontFamily: "JetBrains Mono, JetBrainsMono Nerd Font, FiraCode Nerd Font, monospace"
    readonly property string iconFontFamily: "JetBrainsMono Nerd Font, Iosevka Nerd Font, monospace"
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeRegular: 13
    readonly property int fontSizeMedium: 15
    readonly property int fontSizeLarge: 18
    readonly property int fontSizeClockLarge: 26

    // --- Launcher Tokens (Apple Spotlight Dimensions) ---
    readonly property int launcherWidth: 480
    readonly property int launcherMaxHeight: 400
    readonly property int launcherItemHeight: 46
    readonly property real launcherRadius: 22.0
    readonly property real launcherFillet: 16.0
    readonly property int launcherInputHeight: 42
    readonly property color launcherActiveBg: Qt.rgba(255, 255, 255, 0.12)
    readonly property color launcherActiveBorder: Qt.rgba(255, 255, 255, 0.16)
    readonly property color launcherItemHoverBg: Qt.rgba(255, 255, 255, 0.06)
    readonly property color launcherInputBg: Qt.rgba(255, 255, 255, 0.07)
    readonly property color launcherInputBorder: Qt.rgba(255, 255, 255, 0.12)
    readonly property color launcherScrimBg: Qt.rgba(0, 0, 0, 0.45)

    // --- Menu Bar Tokens (Modern macOS Sonoma / Sequoia borderless glass) ---
    readonly property int barHeight: 32
    readonly property color barBgTop: Qt.rgba(255, 255, 255, 0.12)
    readonly property color barBgBottom: Qt.rgba(255, 255, 255, 0.04)
    readonly property color barBg: Qt.rgba(255, 255, 255, 0.08)
    readonly property color barText: "#ffffff"
    readonly property color barTextMuted: Qt.rgba(255, 255, 255, 0.85)
    readonly property color barBorder: "transparent"
    readonly property color barHighlight: "transparent"
    readonly property color barItemHover: Qt.rgba(255, 255, 255, 0.18)
    // Safe center gap wider than the widest notification pill (480px)
    readonly property int barIslandGap: 500

    // --- System Stats Accent Colors (Apple HIG traffic-light style) ---
    readonly property color statGreen: "#34c759"
    readonly property color statYellow: "#ff9f0a"
    readonly property color statRed: "#ff3b30"

    // --- Battery & Power Management Tokens (Apple macOS HIG / Pure AMOLED) ---
    readonly property color batteryNormal: "#ffffff"
    readonly property color batteryCharging: "#30d158"   // Apple HIG vibrant green
    readonly property color batteryLow: "#ffd60a"        // Apple HIG amber yellow (below 40%)
    readonly property color batteryCritical: "#ff453a"   // Apple HIG red (below 20%)
    readonly property color popoverBg: "#000000"          // 100% Opaque Pure AMOLED Black
    readonly property color popoverCardBg: "#161618"      // 100% Opaque Dark Surface
    readonly property color popoverBorder: Qt.rgba(255, 255, 255, 0.16)
    readonly property color popoverSeparator: Qt.rgba(255, 255, 255, 0.12)
    readonly property real popoverRadius: 16.0
    readonly property int popoverWidth: 320

    // --- Additional animation constants ---
    readonly property int animFast: 120
    readonly property int animMedium: 200
}
