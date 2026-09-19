import QtQuick 2.15
import "../../theme"

// NotificationCard — SoftShell horizontal notification card with top-left floating close button
Rectangle {
    id: root

    property int notifId: 0
    property string appName: "System"
    property string summary: ""
    property string body: ""
    property string appIcon: ""
    property string timeStr: "Just now"

    signal dismissClicked()
    signal cardClicked()

    implicitHeight: 70
    radius: 14
    color: cardMouse.containsMouse ? Theme.cardHover : Theme.cardBg
    border.color: cardMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.20) : Theme.cardBorder
    border.width: 1
    antialiasing: true

    Behavior on color { ColorAnimation { duration: 130 } }
    Behavior on border.color { ColorAnimation { duration: 130 } }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        z: 1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.cardClicked()
    }

    // Circular Dismiss Button at Top-Left Corner (solid opaque white, zero translucency)
    Rectangle {
        id: closeBtn
        width: 18
        height: 18
        radius: 9
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: -5
        anchors.leftMargin: -5
        z: 30
        antialiasing: true
        color: closeMouse.pressed ? "#d0d0d0" : (closeMouse.containsMouse ? "#e8e8e8" : "#ffffff")
        border.width: 0
        opacity: 1.0

        Text {
            anchors.centerIn: parent
            text: "✕"
            font.family: Theme.fontFamily
            font.pixelSize: 8
            font.bold: true
            color: "#000000"
            renderType: Text.NativeRendering
        }

        MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            preventStealing: true
            onClicked: (mouse) => {
                mouse.accepted = true;
                root.dismissClicked();
            }
        }
    }

    // Main Card Content Row
    Row {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        spacing: 12

        // Left: Prominent Squircle App Icon Badge
        NotificationAppIcon {
            id: appBadge
            anchors.verticalCenter: parent.verticalCenter
            appName: root.appName
            summary: root.summary
            body: root.body
            appIcon: root.appIcon
        }

        // Right: 3-Tier Typography Column
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - appBadge.width - parent.spacing
            spacing: 2

            // Line 1: Header Row (App Name / Category + Relative Timestamp)
            Item {
                width: parent.width
                height: 14

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.appName.length > 0 ? root.appName.toUpperCase() : "NOTIFICATION"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.6
                    color: Theme.appleHeaderMuted
                    renderType: Text.NativeRendering
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.timeStr
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.appleHeaderMuted
                    renderType: Text.NativeRendering
                }
            }

            // Line 2: Bold Subject / Title
            Text {
                width: parent.width
                text: root.summary.length > 0 ? root.summary.replace(/[\r\n]+/g, " ") : root.appName
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
                color: Theme.textPrimary
                maximumLineCount: 1
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            // Line 3: Message Body Preview
            Text {
                width: parent.width
                text: root.cleanBody(root.body.length > 0 ? root.body : root.summary)
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.appleSubtext
                maximumLineCount: 1
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }
        }
    }

    function cleanBody(b) {
        if (!b) return "";
        let lines = b.split(/[\r\n]+/).map(l => l.trim()).filter(l => l.length > 0);
        if (lines.length === 0) return "";
        if (lines.length === 1) return lines[0];
        if (lines[0].indexOf(".com") !== -1 || lines[0].indexOf(".org") !== -1 || lines[0].indexOf(".net") !== -1 || lines[0].indexOf("http") !== -1) {
            return lines.slice(1).join(" ");
        }
        return lines.join(" ");
    }
}
