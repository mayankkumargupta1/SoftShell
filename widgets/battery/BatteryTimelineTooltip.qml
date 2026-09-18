import QtQuick 2.15
import "../../theme"

// BatteryTimelineTooltip — Floating hover card tooltip for timeline items
Rectangle {
    id: root

    property var itemData: null

    implicitWidth: contentCol.implicitWidth + 16
    implicitHeight: contentCol.implicitHeight + 14
    radius: 7
    color: "#202024"
    border.color: Theme.popoverBorder
    border.width: 1

    function computeColor(pct, state) {
        if (!pct && pct !== 0) pct = 100;
        let t = Math.max(0.0, Math.min(1.0, (pct - 20.0) / 80.0));
        let r = Math.round(10 + (48 - 10) * t);
        let g = Math.round(132 + (209 - 132) * t);
        let b = Math.round(255 - (255 - 88) * t);
        return Qt.rgba(r / 255.0, g / 255.0, b / 255.0, 1.0);
    }

    readonly property color statusColor: {
        if (!itemData) return "#30d158";
        return computeColor(itemData.percentage, itemData.state);
    }

    readonly property string stateText: {
        if (!itemData) return "Normal";
        if (itemData.state === "charging" || itemData.state === "fully-charged") {
            return "On Power Adapter";
        }
        return "On Battery";
    }

    Column {
        id: contentCol
        anchors.centerIn: parent
        spacing: 5

        // Timestamp Header
        Text {
            text: root.itemData ? root.itemData.timeLabel : ""
            font.family: Theme.fontFamily
            font.pixelSize: 10
            font.weight: Font.Medium
            color: Theme.textSecondary
            renderType: Text.NativeRendering
        }

        // Hairline Separator
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.popoverSeparator
        }

        // Status Row: Dot + State + Percentage
        Row {
            spacing: 8

            // Colored Indicator Dot
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 7
                height: 7
                radius: 3.5
                color: root.statusColor
            }

            // State Description
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.stateText
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: "#ffffff"
                renderType: Text.NativeRendering
            }

            // Battery Percentage
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: (root.itemData ? root.itemData.percentage : 100) + "%"
                font.family: Theme.monoFontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: Theme.textSecondary
                renderType: Text.NativeRendering
            }
        }
    }
}
