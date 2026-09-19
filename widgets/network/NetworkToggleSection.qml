import QtQuick 2.15
import "../../theme"
import "../../services"

// NetworkToggleSection — Sleek top row with "Wi-Fi" title and SoftShell toggle switch
Item {
    id: root

    property NetworkService networkService: null

    implicitWidth: parent ? parent.width : 250
    implicitHeight: 26

    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: "Wi-Fi"
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: "#ffffff"
        renderType: Text.NativeRendering
    }

    // Toggle Switch on right
    Rectangle {
        id: toggleTrack
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 38
        height: 22
        radius: 11
        color: (root.networkService && root.networkService.wifiEnabled) ? "#007aff" : "#323236"
        Behavior on color { ColorAnimation { duration: 150 } }

        Rectangle {
            id: toggleThumb
            width: 18
            height: 18
            radius: 9
            color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            x: (root.networkService && root.networkService.wifiEnabled) ? (parent.width - width - 2) : 2
            Behavior on x {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: switchArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.networkService) {
                    root.networkService.toggleWifi(!root.networkService.wifiEnabled);
                }
            }
        }
    }
}
