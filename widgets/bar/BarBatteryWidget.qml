import QtQuick 2.15
import "../../theme"
import "../../services"

// BarBatteryWidget — Battery percentage with glyph that matches charge level.
// Color: green >40%, yellow >20%, red ≤20%.  Charging shows bolt glyph.
Item {
    id: root

    property SystemStatsService stats: null

    implicitWidth: batRow.implicitWidth
    implicitHeight: Theme.barHeight

    function batteryColor() {
        if (!stats) return Theme.barText;
        if (stats.isCharging) return Theme.batteryCharging;
        if (stats.batteryPercent <= 20) return Theme.batteryCritical;
        if (stats.batteryPercent <= 40) return Theme.batteryLow;
        return Theme.barText;
    }

    function batteryGlyph() {
        if (!stats) return "󰁹";
        if (stats.isCharging) return "󰂄";
        let p = stats.batteryPercent;
        if (p >= 95) return "󰁹";
        if (p >= 80) return "󰂁";
        if (p >= 65) return "󰂀";
        if (p >= 50) return "󰁿";
        if (p >= 35) return "󰁾";
        if (p >= 20) return "󰁼";
        if (p >= 10) return "󰁻";
        return "󰁺";
    }

    Row {
        id: batRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.batteryGlyph()
            font.family: Theme.iconFontFamily
            font.pixelSize: 13
            color: root.batteryColor()
            renderType: Text.NativeRendering
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.stats ? root.stats.batteryPercent + "%" : "—"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            color: root.batteryColor()
            renderType: Text.NativeRendering
        }
    }
}
