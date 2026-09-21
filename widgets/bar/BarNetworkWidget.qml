import QtQuick 2.15
import "../../theme"
import "../../services"

// BarNetworkWidget — WiFi SSID + signal strength glyph (read-only, no click action).
Item {
    id: root

    property SystemStatsService stats: null

    implicitWidth: netRow.implicitWidth
    implicitHeight: Theme.barHeight

    function wifiGlyph() {
        if (!stats) return "󰤨";
        if (stats.ethernetConnected && !stats.wifiConnected) return "󰈀";
        if (!stats.wifiEnabled) return "󰤮";
        if (!stats.wifiConnected || stats.connectivity === "none") return "󰤭";
        if (stats.connectivity === "portal" || stats.connectivity === "limited") return "󰤩";
        let q = stats.wifiSignalQuality;
        if (q >= 75) return "󰤨";
        if (q >= 50) return "󰤥";
        if (q >= 25) return "󰤢";
        if (q > 0)   return "󰤟";
        return "󰤯";
    }

    function wifiColor() {
        if (!stats) return Theme.barText;
        if (!stats.wifiEnabled) return Qt.rgba(255, 255, 255, 0.35);
        if ((!stats.wifiConnected && !stats.ethernetConnected) || stats.connectivity === "none") {
            return Qt.rgba(255, 255, 255, 0.45);
        }
        if (stats.connectivity === "portal" || stats.connectivity === "limited") {
            return Theme.statYellow;
        }
        return Theme.barText;
    }

    Row {
        id: netRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        // Signal glyph
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.wifiGlyph()
            font.family: Theme.iconFontFamily
            font.pixelSize: 12
            color: root.wifiColor()
            renderType: Text.NativeRendering
        }

        // SSID name — truncated at 14 chars
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!root.stats) return "";
                if (root.stats.ethernetConnected && !root.stats.wifiConnected) return "Ethernet";
                if (!root.stats.wifiEnabled) return "Wi-Fi Off";
                if (!root.stats.wifiConnected) return "Not Connected";
                if (root.stats.connectivity === "none") return "No Internet";
                let ssid = root.stats.wifiSsid;
                return ssid.length > 14 ? ssid.substring(0, 13) + "…" : ssid;
            }
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            color: root.wifiColor()
            renderType: Text.NativeRendering
        }
    }
}
