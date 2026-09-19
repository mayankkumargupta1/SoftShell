import QtQuick 2.15
import "../../theme"
import "../../services"

// OtherNetworksSection — Expandable "Other Networks" list matching SoftShell layout
Item {
    id: root

    property NetworkService networkService: null
    property bool expanded: false
    signal passwordRequested(string ssid)

    implicitWidth: parent ? parent.width : 255
    implicitHeight: mainCol.implicitHeight

    readonly property var activeSsid: (root.networkService && root.networkService.activeWifi) ? root.networkService.activeWifi.ssid : ""

    readonly property var otherList: {
        if (!root.networkService || !root.networkService.nearbyNetworks) return [];
        let list = [];
        for (let i = 0; i < root.networkService.nearbyNetworks.length; i++) {
            let item = root.networkService.nearbyNetworks[i];
            if (item.ssid !== root.activeSsid) {
                list.push(item);
            }
        }
        return list;
    }

    Column {
        id: mainCol
        width: parent.width
        spacing: 4

        // -------------------------------------------------------------------
        // Header Row: "Other Networks" + Rotating Chevron ">"
        // -------------------------------------------------------------------
        Item {
            width: parent.width
            height: 26

            Rectangle {
                anchors.fill: parent
                radius: 5
                color: headerHover.hovered ? Theme.barItemHover : "transparent"
                Behavior on color { ColorAnimation { duration: 90 } }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                text: "Other Networks"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                color: "#c4a377"
                renderType: Text.NativeRendering
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                // Refresh spinner (when scanning)
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.networkService ? root.networkService.isScanning : false
                    text: "󰑐"
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 12
                    color: Theme.textSecondary
                    renderType: Text.NativeRendering
                    rotation: spinAnim.angle

                    NumberAnimation on rotation {
                        id: spinAnim
                        property real angle: 0
                        running: root.networkService ? root.networkService.isScanning : false
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 800
                    }
                }

                // Chevron ">" that rotates to 90° ("v") when expanded
                Text {
                    id: chevron
                    anchors.verticalCenter: parent.verticalCenter
                    text: "›"
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    color: Theme.textSecondary
                    renderType: Text.NativeRendering
                    rotation: root.expanded ? 90 : 0
                    Behavior on rotation {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            HoverHandler {
                id: headerHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: {
                    root.expanded = !root.expanded;
                    if (root.expanded && root.networkService) {
                        root.networkService.scanNetworks();
                    }
                }
            }
        }

        // -------------------------------------------------------------------
        // Collapsible Networks List
        // -------------------------------------------------------------------
        Item {
            id: listWrap
            width: parent.width
            implicitHeight: root.expanded ? listCol.implicitHeight : 0
            height: implicitHeight
            clip: true
            visible: height > 0

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            Column {
                id: listCol
                width: parent.width
                spacing: 2

                Repeater {
                    model: root.otherList.slice(0, 7)

                    NetworkItemRow {
                        width: parent.width
                        networkData: modelData
                        isConnecting: root.networkService ? (root.networkService.isConnecting && root.networkService.connectingSsid === modelData.ssid) : false
                        onClicked: {
                            if (!root.networkService) return;
                            if (modelData.isKnown || !modelData.isSecured) {
                                root.networkService.connectToNetwork(modelData.ssid, "");
                            } else {
                                root.passwordRequested(modelData.ssid);
                            }
                        }
                    }
                }

                // Empty State
                Text {
                    visible: root.otherList.length === 0
                    width: parent.width
                    height: 24
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: (root.networkService && !root.networkService.wifiEnabled) ? "Wi-Fi is turned off" : "No other networks found"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.textTertiary
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
