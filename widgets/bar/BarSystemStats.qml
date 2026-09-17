import QtQuick 2.15
import "../../theme"
import "../../services"

// BarSystemStats — CPU%, RAM, and CPU Temperature inline stat chips.
// Color-coded: green → yellow → red as values rise.
Item {
    id: root

    property SystemStatsService stats: null

    implicitWidth: statsRow.implicitWidth
    implicitHeight: Theme.barHeight

    // Color helpers — Apple monochrome by default, amber/red only under heavy load
    function cpuColor() {
        if (!stats) return Theme.barText;
        if (stats.cpuPercent >= 90) return Theme.statRed;
        if (stats.cpuPercent >= 80) return Theme.statYellow;
        return Theme.barText;
    }
    function tempColor() {
        if (!stats) return Theme.barText;
        if (stats.cpuTempC >= 85) return Theme.statRed;
        if (stats.cpuTempC >= 75) return Theme.statYellow;
        return Theme.barText;
    }
    function ramColor() {
        if (!stats) return Theme.barText;
        if (stats.ramPercent >= 90) return Theme.statRed;
        if (stats.ramPercent >= 80) return Theme.statYellow;
        return Theme.barText;
    }

    Row {
        id: statsRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        // CPU %
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰻠"
                font.family: Theme.iconFontFamily
                font.pixelSize: 11
                color: root.cpuColor()
                renderType: Text.NativeRendering
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.stats ? root.stats.cpuPercent + "%" : "—"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: root.cpuColor()
                renderType: Text.NativeRendering
            }
        }

        // RAM
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰍛"
                font.family: Theme.iconFontFamily
                font.pixelSize: 11
                color: root.ramColor()
                renderType: Text.NativeRendering
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.stats ? root.stats.ramUsedGb + "G" : "—"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: root.ramColor()
                renderType: Text.NativeRendering
            }
        }

        // CPU Temperature
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󱃃"
                font.family: Theme.iconFontFamily
                font.pixelSize: 11
                color: root.tempColor()
                renderType: Text.NativeRendering
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.stats ? root.stats.cpuTempC + "°" : "—"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: root.tempColor()
                renderType: Text.NativeRendering
            }
        }
    }
}
