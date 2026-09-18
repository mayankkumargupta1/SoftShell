import QtQuick 2.15
import "../../theme"

// BatteryIcon — Authentic SoftShell Battery Glyph with dynamic level & state colors
Item {
    id: root

    property int percentage: 100
    property bool isCharging: false

    implicitWidth: 25
    implicitHeight: 12

    // Dynamic fill color according to user requirements & SoftShell HIG:
    // - Below 20%: Red (#ff453a)
    // - Below 40%: Yellow (#ffd60a)
    // - Charging: Green (#30d158)
    // - Normal: White (#ffffff)
    readonly property color fillColor: {
        if (isCharging) return Theme.batteryCharging;
        if (percentage <= 20) return Theme.batteryCritical;
        if (percentage <= 40) return Theme.batteryLow;
        return Theme.batteryNormal;
    }

    readonly property color outlineColor: {
        if (isCharging) return Theme.batteryCharging;
        if (percentage <= 20) return Theme.batteryCritical;
        if (percentage <= 40) return Theme.batteryLow;
        return Theme.barText;
    }

    // Battery Body Capsule Outline
    Rectangle {
        id: batOutline
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 3
        height: parent.height - 1
        radius: 3
        color: "transparent"
        border.color: root.outlineColor
        border.width: 1
        antialiasing: true

        Behavior on border.color { ColorAnimation { duration: 150 } }

        // Battery Fill Level
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            width: Math.max(2, Math.round((parent.width - 4) * (Math.min(100, Math.max(0, root.percentage)) / 100.0)))
            radius: 1.5
            color: root.fillColor
            antialiasing: true

            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        // Charging Lightning Symbol
        Text {
            anchors.centerIn: parent
            visible: root.isCharging
            text: "󱐋"
            font.family: Theme.iconFontFamily
            font.pixelSize: 9
            color: root.percentage > 55 ? "#1c1c1e" : Theme.batteryCharging
            renderType: Text.NativeRendering
            z: 2
        }
    }

    // Positive Terminal Nub
    Rectangle {
        anchors.left: batOutline.right
        anchors.leftMargin: 1
        anchors.verticalCenter: batOutline.verticalCenter
        width: 1.5
        height: 4.5
        radius: 0.75
        color: root.outlineColor
        antialiasing: true

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
