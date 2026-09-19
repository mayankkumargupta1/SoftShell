import QtQuick 2.15
import "../../theme"
import "../../services"

// NetworkPasswordView — Modern SoftShell "Join Network" view with back link and pill buttons
Item {
    id: root

    property NetworkService networkService: null
    property string targetSsid: ""
    signal cancelRequested()

    implicitWidth: parent ? parent.width : 255
    implicitHeight: contentCol.implicitHeight

    property bool showPassword: false

    function reset() {
        pwdInput.text = "";
        showPassword = false;
        if (root.networkService) root.networkService.connectError = "";
    }

    onVisibleChanged: {
        if (visible) {
            pwdInput.text = "";
            pwdInput.forceActiveFocus();
        }
    }

    Column {
        id: contentCol
        width: parent.width
        spacing: 12

        // -------------------------------------------------------------------
        // Navigation Header: "‹ Wi-Fi" back button (matching "‹ Battery")
        // -------------------------------------------------------------------
        Item {
            width: parent.width
            height: 22

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: backRow.implicitWidth + 8
                height: 20
                radius: 4
                color: backHover.hovered ? Theme.barItemHover : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }

                Row {
                    id: backRow
                    anchors.centerIn: parent
                    spacing: 3

                    Text {
                        text: "‹"
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: "#0a84ff"
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: "Wi-Fi"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#0a84ff"
                        renderType: Text.NativeRendering
                    }
                }

                HoverHandler {
                    id: backHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.cancelRequested()
                }
            }
        }

        // -------------------------------------------------------------------
        // Center: Network Badge & Title
        // -------------------------------------------------------------------
        Column {
            width: parent.width
            spacing: 6
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 34
                height: 34
                radius: 17
                color: "#007aff"

                Text {
                    anchors.centerIn: parent
                    text: "󰤨"
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 16
                    color: "#ffffff"
                    renderType: Text.NativeRendering
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Join \"" + root.targetSsid + "\""
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: "#ffffff"
                elide: Text.ElideMiddle
                width: Math.min(parent.width, 240)
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Enter the password for this network."
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.textSecondary
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
            }
        }

        // -------------------------------------------------------------------
        // Password Input Box
        // -------------------------------------------------------------------
        Rectangle {
            id: inputWrap
            width: parent.width
            height: 30
            radius: 6
            color: "#18181b"
            border.color: pwdInput.activeFocus ? "#007aff" : Theme.popoverBorder
            border.width: pwdInput.activeFocus ? 1.5 : 1

            TextInput {
                id: pwdInput
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: eyeBtn.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: "#ffffff"
                selectionColor: "#007aff"
                selectByMouse: true
                renderType: Text.NativeRendering
                onAccepted: {
                    if (pwdInput.text.length > 0 && root.networkService && !root.networkService.isConnecting) {
                        root.networkService.connectToNetwork(root.targetSsid, pwdInput.text);
                    }
                }

                Text {
                    anchors.fill: parent
                    visible: !pwdInput.text && !pwdInput.activeFocus
                    text: "Password"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.textTertiary
                    renderType: Text.NativeRendering
                }
            }

            // Eye Show/Hide Toggle
            Item {
                id: eyeBtn
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 26
                height: parent.height

                Text {
                    anchors.centerIn: parent
                    text: root.showPassword ? "󰈈" : "󰈉"
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 13
                    color: eyeHover.hovered ? "#ffffff" : Theme.textSecondary
                    renderType: Text.NativeRendering
                }

                HoverHandler {
                    id: eyeHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.showPassword = !root.showPassword
                }
            }
        }

        // Error message
        Text {
            visible: root.networkService ? (root.networkService.connectError.length > 0 && root.networkService.connectingSsid === root.targetSsid) : false
            width: parent.width
            wrapMode: Text.WordWrap
            text: root.networkService ? root.networkService.connectError : ""
            font.family: Theme.fontFamily
            font.pixelSize: 10
            color: "#ff453a"
            horizontalAlignment: Text.AlignHCenter
            renderType: Text.NativeRendering
        }

        // -------------------------------------------------------------------
        // Action Buttons: Cancel and Join (SoftShell Style)
        // -------------------------------------------------------------------
        Row {
            anchors.right: parent.right
            spacing: 8

            // Cancel Button
            Rectangle {
                width: 58
                height: 24
                radius: 5
                color: cancelHover.hovered ? "#323238" : "#242428"
                border.color: Theme.popoverBorder
                border.width: 1
                Behavior on color { ColorAnimation { duration: 90 } }

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: "#ffffff"
                    renderType: Text.NativeRendering
                }

                HoverHandler {
                    id: cancelHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.cancelRequested()
                }
            }

            // Join Button
            Rectangle {
                readonly property bool canJoin: pwdInput.text.length > 0 && !(root.networkService && root.networkService.isConnecting)
                width: 54
                height: 24
                radius: 5
                color: canJoin ? (joinHover.hovered ? "#0062cc" : "#007aff") : "#242428"
                Behavior on color { ColorAnimation { duration: 90 } }

                Text {
                    anchors.centerIn: parent
                    text: (root.networkService && root.networkService.isConnecting) ? "Joining..." : "Join"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: parent.canJoin ? "#ffffff" : Theme.textTertiary
                    renderType: Text.NativeRendering
                }

                HoverHandler {
                    id: joinHover
                    cursorShape: parent.canJoin ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

                TapHandler {
                    enabled: parent.canJoin
                    onTapped: {
                        if (root.networkService) {
                            root.networkService.connectToNetwork(root.targetSsid, pwdInput.text);
                        }
                    }
                }
            }
        }
    }
}
