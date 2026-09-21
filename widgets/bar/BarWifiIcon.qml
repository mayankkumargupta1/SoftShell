import QtQuick 2.15
import "../../theme"

// BarWifiIcon — Dynamic SoftShell Network Status Glyph
// Automatically reflects:
// - Ethernet connected: 󰈀
// - Wi-Fi disabled: 󰤮 (dimmed)
// - Disconnected / No internet: 󰤭 (dimmed)
// - Captive Portal / Limited: 󰤩 (amber)
// - Connected: 󰤨 / 󰤥 / 󰤢 / 󰤟 / 󰤯 (dynamic signal bars, white)
Item {
    id: root

    property bool wifiConnected: false
    property bool wifiEnabled: true
    property bool ethernetConnected: false
    property int signalQuality: 0
    property string connectivity: "full" // "full", "limited", "portal", "none", "unknown"

    implicitWidth: 18
    implicitHeight: 18

    readonly property string iconGlyph: {
        // 1. Ethernet connected (wired cable)
        if (root.ethernetConnected && !root.wifiConnected) {
            return "󰈀";
        }

        // 2. Wi-Fi disabled / radio turned off
        if (!root.wifiEnabled) {
            return "󰤮";
        }

        // 3. Wi-Fi enabled but disconnected from any network
        if (!root.wifiConnected) {
            return "󰤭";
        }

        // 4. Connected to network but no internet
        if (root.connectivity === "none") {
            return "󰤭";
        }

        // 5. Captive portal or limited connectivity
        if (root.connectivity === "portal" || root.connectivity === "limited") {
            return "󰤩";
        }

        // 6. Active Wi-Fi with internet — dynamic signal tiers
        let q = root.signalQuality;
        if (q >= 75) return "󰤨";
        if (q >= 50) return "󰤥";
        if (q >= 25) return "󰤢";
        if (q > 0)   return "󰤟";
        return "󰤯";
    }

    readonly property color iconColor: {
        // Wi-Fi radio off
        if (!root.wifiEnabled) {
            return Qt.rgba(255, 255, 255, 0.35);
        }

        // Disconnected from network or no internet
        if (!root.wifiConnected && !root.ethernetConnected) {
            return Qt.rgba(255, 255, 255, 0.45);
        }
        if (root.connectivity === "none") {
            return Qt.rgba(255, 255, 255, 0.45);
        }

        // Captive portal / limited
        if (root.connectivity === "portal" || root.connectivity === "limited") {
            return Theme.statYellow;
        }

        // Normal connected
        return Theme.barText;
    }

    Text {
        anchors.centerIn: parent
        text: root.iconGlyph
        font.family: Theme.iconFontFamily
        font.pixelSize: 15
        color: root.iconColor
        renderType: Text.NativeRendering

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
