import QtQuick 2.15
import "../../theme"

// NetworkPasswordModal — Modal dialog for entering Wi-Fi network password
Item {
    id: root

    property string targetSsid: ""
    property string errorMessage: ""
    property bool isConnecting: false
    property bool showPassword: false

    signal cancelRequested()
    signal submitPassword(string password)

    anchors.fill: parent

    function reset() {
        pwdInput.text = "";
        showPassword = false;
    }

    onVisibleChanged: {
        if (visible) {
            pwdInput.forceActiveFocus();
        }
    }

    // Modal Dim Backdrop
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.70)
        radius: 10

        MouseArea {
            anchors.fill: parent
            // Prevent clicks from penetrating to underlying cards
            onClicked: {}
        }
    }

    // Centered Dialog Box
    Rectangle {
        id: dialogBox
        anchors.centerIn: parent
        width: Math.min(parent.width - 24, 320)
        implicitHeight: dialogCol.implicitHeight + 24
        radius: 10
        color: "#1a1a1e"
        border.color: Theme.popoverBorder
        border.width: 1

        Column {
            id: dialogCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 12

            // Title & Subtitle
            Column {
                width: parent.width
                spacing: 4

                Text {
                    text: "Enter Password"
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: "#ffffff"
                    renderType: Text.NativeRendering
                }

                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: "The network \"" + root.targetSsid + "\" requires a password."
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.textSecondary
                    renderType: Text.NativeRendering
                }
            }

            // Input Field
            Rectangle {
                id: inputWrap
                width: parent.width
                height: 32
                radius: 6
                color: "#121214"
                border.color: pwdInput.activeFocus ? "#007aff" : Theme.popoverBorder
                border.width: 1

                TextInput {
                    id: pwdInput
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.right: eyeBtn.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: "#ffffff"
                    selectionColor: "#007aff"
                    selectByMouse: true
                    renderType: Text.NativeRendering
                    onAccepted: {
                        if (pwdInput.text.length > 0 && !root.isConnecting) {
                            root.submitPassword(pwdInput.text);
                        }
                    }

                    Text {
                        anchors.fill: parent
                        visible: !pwdInput.text && !pwdInput.activeFocus
                        text: "Password"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.textTertiary
                        renderType: Text.NativeRendering
                    }
                }

                // Show/Hide Password Eye Button
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
                        font.pixelSize: 14
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

            // Error Message (if any)
            Text {
                visible: root.errorMessage.length > 0
                width: parent.width
                wrapMode: Text.WordWrap
                text: root.errorMessage
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: "#ff453a"
                renderType: Text.NativeRendering
            }

            // Action Buttons (Cancel / Connect)
            Row {
                anchors.right: parent.right
                spacing: 8

                // Cancel Button
                Rectangle {
                    width: cancelText.implicitWidth + 20
                    height: 26
                    radius: 5
                    color: cancelHover.hovered ? "#2e2e34" : "#222226"
                    border.color: Theme.popoverBorder
                    border.width: 1

                    Text {
                        id: cancelText
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

                // Connect Button
                Rectangle {
                    width: connectText.implicitWidth + 22
                    height: 26
                    radius: 5
                    color: (pwdInput.text.length > 0 && !root.isConnecting) ? (connectHover.hovered ? "#0062cc" : "#007aff") : "#323236"

                    Text {
                        id: connectText
                        anchors.centerIn: parent
                        text: root.isConnecting ? "Connecting..." : "Connect"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: (pwdInput.text.length > 0 && !root.isConnecting) ? "#ffffff" : Theme.textSecondary
                        renderType: Text.NativeRendering
                    }

                    HoverHandler {
                        id: connectHover
                        cursorShape: (pwdInput.text.length > 0 && !root.isConnecting) ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }

                    TapHandler {
                        enabled: pwdInput.text.length > 0 && !root.isConnecting
                        onTapped: root.submitPassword(pwdInput.text)
                    }
                }
            }
        }
    }
}
