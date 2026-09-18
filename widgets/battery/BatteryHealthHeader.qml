import QtQuick 2.15
import "../../theme"
import "../../services"

// BatteryHealthHeader — Section 1: Health status pill card matching SoftShell design
Rectangle {
    id: root

    property PowerService powerService: null

    implicitWidth: parent ? parent.width : 380
    implicitHeight: 38
    radius: 8
    color: "#161618"
    border.color: Theme.popoverBorder
    border.width: 1

    readonly property string category: root.powerService ? root.powerService.healthCategory : "Excellent"
    readonly property int healthPercent: root.powerService ? Math.round(root.powerService.health) : 100

    readonly property color statusColor: {
        switch (root.category) {
            case "Excellent": return "#30d158";
            case "Good":      return "#30d158";
            case "Normal":    return "#32d74b";
            case "Needs Help":return "#ffd60a";
            case "Critical":  return "#ff453a";
            default:          return "#30d158";
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        // Left: "Battery Health"
        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Battery Health"
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.weight: Font.Medium
            color: "#ffffff"
            renderType: Text.NativeRendering
        }

        // Right: "Excellent 99%"
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.category + " " + root.healthPercent + "%"
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: root.statusColor
            renderType: Text.NativeRendering
        }
    }
}
