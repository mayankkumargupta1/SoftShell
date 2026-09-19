import QtQuick 2.15
import "../../theme"

// NetworkItemRow — Reusable row for a Wi-Fi network item
Item {
    id: root

    property var networkData: null
    property bool isConnecting: false
    signal clicked()

    implicitWidth: parent ? parent.width : 245
    implicitHeight: 26

    readonly property string ssid: (networkData && networkData.ssid) ? networkData.ssid : ""
    readonly property int signalVal: (networkData && networkData.signal) ? networkData.signal : 0
    readonly property bool isSecured: (networkData && networkData.isSecured) ? networkData.isSecured : false
    readonly property bool inUse: (networkData && networkData.inUse) ? networkData.inUse : false

    function wifiGlyph(sig) {
        if (sig >= 75) return "󰤨";
        if (sig >= 50) return "󰤥";
        if (sig >= 25) return "󰤢";
        return "󰤟";
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 4
        color: rowHover.hovered ? Theme.barItemHover : "transparent"
        Behavior on color { ColorAnimation { duration: 90 } }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.right: rightIcons.left
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Wi-Fi Signal Strength Glyph
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.wifiGlyph(root.signalVal)
            font.family: Theme.iconFontFamily
            font.pixelSize: 14
            color: root.inUse ? "#007aff" : (rowHover.hovered ? "#ffffff" : Theme.textSecondary)
            renderType: Text.NativeRendering
        }

        // SSID Label
        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 24
            text: root.ssid
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: root.inUse ? Font.DemiBold : Font.Normal
            color: "#ffffff"
            elide: Text.ElideRight
            renderType: Text.NativeRendering
        }
    }

    // Right-aligned status / lock icons
    Row {
        id: rightIcons
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        // Connecting Indicator
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.isConnecting
            text: "Connecting..."
            font.family: Theme.fontFamily
            font.pixelSize: 10
            color: "#007aff"
            renderType: Text.NativeRendering
        }

        // In-use checkmark
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.inUse && !root.isConnecting
            text: "✓"
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Bold
            color: "#007aff"
            renderType: Text.NativeRendering
        }

        // Lock icon
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.isSecured && !root.inUse
            text: "󰌾"
            font.family: Theme.iconFontFamily
            font.pixelSize: 12
            color: Theme.textSecondary
            renderType: Text.NativeRendering
        }
    }

    HoverHandler {
        id: rowHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
