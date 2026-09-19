import QtQuick 2.15
import "../../theme"
import "../../services"

// NetworkCard — Sleek unified AMOLED black container with smooth password view transition
Rectangle {
    id: root

    property NetworkService networkService: null
    property bool isPasswordView: false
    property string targetSsid: ""

    implicitWidth: 275
    implicitHeight: (isPasswordView ? pwdView.implicitHeight : mainCol.implicitHeight) + 20
    radius: 10
    color: "#000000" // 100% Pure AMOLED Black
    border.color: Theme.popoverBorder
    border.width: 1
    clip: false

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    function reset() {
        isPasswordView = false;
        targetSsid = "";
        otherSec.expanded = false;
        pwdView.reset();
    }

    Connections {
        target: root.networkService
        function onConnectionFinished(success, error) {
            if (success) {
                root.isPasswordView = false;
                root.targetSsid = "";
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 10

        // -------------------------------------------------------------------
        // 1. Main Network View
        // -------------------------------------------------------------------
        Column {
            id: mainCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 8
            visible: opacity > 0
            opacity: root.isPasswordView ? 0 : 1
            scale: root.isPasswordView ? 0.96 : 1.0

            Behavior on opacity { NumberAnimation { duration: 160 } }
            Behavior on scale { NumberAnimation { duration: 160 } }

            // 1. Wi-Fi Toggle Row
            NetworkToggleSection {
                width: parent.width
                networkService: root.networkService
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.popoverSeparator
            }

            // 2. Preferred / Known Network Section
            KnownNetworkSection {
                width: parent.width
                networkService: root.networkService
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.popoverSeparator
            }

            // 3. Other Networks (Expandable)
            OtherNetworksSection {
                id: otherSec
                width: parent.width
                networkService: root.networkService
                onPasswordRequested: ssid => {
                    root.targetSsid = ssid;
                    root.isPasswordView = true;
                }
            }

            // Optional Divider (only if Ethernet is connected)
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.popoverSeparator
                visible: ethSec.visible
            }

            // 4. Ethernet Section (only shown when connected)
            EthernetSection {
                id: ethSec
                width: parent.width
                networkService: root.networkService
            }
        }

        // -------------------------------------------------------------------
        // 2. SoftShell Password / Join View
        // -------------------------------------------------------------------
        NetworkPasswordView {
            id: pwdView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            networkService: root.networkService
            targetSsid: root.targetSsid
            visible: opacity > 0
            opacity: root.isPasswordView ? 1 : 0
            scale: root.isPasswordView ? 1.0 : 0.96

            Behavior on opacity { NumberAnimation { duration: 160 } }
            Behavior on scale { NumberAnimation { duration: 160 } }

            onCancelRequested: {
                root.isPasswordView = false;
                root.targetSsid = "";
                pwdView.reset();
            }
        }
    }
}
