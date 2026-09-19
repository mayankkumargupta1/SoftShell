import QtQuick 2.15
import "../../theme"
import "../../services"

// EthernetSection — Ethernet interface status, only shown when actively connected
Item {
    id: root

    property NetworkService networkService: null

    readonly property var eth: root.networkService ? root.networkService.ethernet : null
    readonly property bool isConnected: eth !== null && eth.state === "connected"

    visible: isConnected
    implicitWidth: parent ? parent.width : 250
    implicitHeight: isConnected ? contentCol.implicitHeight : 0

    Column {
        id: contentCol
        width: parent.width
        spacing: 6

        // Section Title
        Text {
            text: "Ethernet"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            color: "#c4a377"
            renderType: Text.NativeRendering
        }

        // Ethernet Status Row
        Item {
            width: parent.width
            height: 28

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // Green Circular Ethernet Badge
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: "#30d158"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰈀"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 12
                        color: "#ffffff"
                        renderType: Text.NativeRendering
                    }
                }

                // Interface Details
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        text: (root.eth && root.eth.device) ? ("Wired (" + root.eth.device + ")") : "Wired Interface"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#ffffff"
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: "Connected"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.accentGreen
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }
}
