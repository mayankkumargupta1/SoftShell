import QtQuick 2.15
import "../../theme"
import "../../services"

// KnownNetworkSection — "Preferred Network" section with blue text links for Disconnect and Forget
Item {
    id: root

    property NetworkService networkService: null

    implicitWidth: parent ? parent.width : 255
    implicitHeight: contentCol.implicitHeight

    readonly property var active: root.networkService ? root.networkService.activeWifi : null
    readonly property bool hasActive: active !== null && active.ssid !== undefined && active.ssid.length > 0

    Column {
        id: contentCol
        width: parent.width
        spacing: 5

        // Header: "Preferred Network" in subtle warm muted tone
        Text {
            text: "Preferred Network"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            color: "#c4a377"
            renderType: Text.NativeRendering
        }

        // Network Row
        Item {
            width: parent.width
            height: 32

            Rectangle {
                anchors.fill: parent
                radius: 5
                color: rowHover.hovered ? Theme.barItemHover : "transparent"
                Behavior on color { ColorAnimation { duration: 90 } }
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.right: rightArea.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // Blue Circular Wi-Fi Badge
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: root.hasActive ? "#007aff" : "#2a2a2e"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰤨"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 12
                        color: "#ffffff"
                        renderType: Text.NativeRendering
                    }
                }

                // SSID
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 32
                    text: root.hasActive ? root.active.ssid : (root.networkService && root.networkService.wifiEnabled ? "Not Connected" : "Wi-Fi is Off")
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: "#ffffff"
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                }
            }

            // Right side: Lock Glyph and Blue Text Links (Disconnect / Forget)
            Row {
                id: rightArea
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                // Lock icon if secured
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.hasActive && root.active.isSecured
                    text: "󰌾"
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 11
                    color: Theme.textSecondary
                    renderType: Text.NativeRendering
                }

                // Disconnect Link (SoftShell blue text link matching "< Battery")
                Item {
                    id: disconBtn
                    visible: root.hasActive
                    width: disconText.implicitWidth + 8
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: disconHov.hovered ? Theme.barItemHover : "transparent"
                        Behavior on color { ColorAnimation { duration: 90 } }
                    }

                    Text {
                        id: disconText
                        anchors.centerIn: parent
                        text: "Disconnect"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: "#0a84ff"
                        renderType: Text.NativeRendering
                    }

                    HoverHandler {
                        id: disconHov
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            if (root.networkService) root.networkService.disconnectWifi();
                        }
                    }
                }

                // Forget Link (SoftShell blue text link matching "< Battery")
                Item {
                    id: forgetBtn
                    visible: root.hasActive
                    width: forgetText.implicitWidth + 8
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: forgetHov.hovered ? Theme.barItemHover : "transparent"
                        Behavior on color { ColorAnimation { duration: 90 } }
                    }

                    Text {
                        id: forgetText
                        anchors.centerIn: parent
                        text: "Forget"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: "#0a84ff"
                        renderType: Text.NativeRendering
                    }

                    HoverHandler {
                        id: forgetHov
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            if (root.networkService && root.hasActive) {
                                root.networkService.forgetNetwork(root.active.ssid);
                            }
                        }
                    }
                }
            }

            HoverHandler {
                id: rowHover
                cursorShape: Qt.ArrowCursor
            }
        }
    }
}
