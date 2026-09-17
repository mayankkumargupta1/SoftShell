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
        if (!stats || !stats.wifiConnected) return "󰤭";
        let q = stats.wifiSignalQuality;
        if (q >= 80) return "󰤨";
        if (q >= 55) return "󰤥";
        if (q >= 35) return "󰤢";
        if (q >= 10) return "󰤟";
        return "󰤯";
    }

    function wifiColor() {
        if (!stats || !stats.wifiConnected) return Theme.barMuted;
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
                if (!root.stats || !root.stats.wifiConnected) return "No Wi-Fi";
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
