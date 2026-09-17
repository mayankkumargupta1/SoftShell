import QtQuick 2.15
import "../../theme"
import "../../services"

Item {
    id: root

    property NotificationService notifService: null

    implicitHeight: 42
    implicitWidth: bannerRow.implicitWidth

    readonly property var currentNotif: notifService ? notifService.activeBanner : null
    readonly property int queueCount: notifService ? notifService.bannerQueueCount : 0

    // Authentic Apple app colors
    function getAppColor(appName) {
        let name = (appName || "").toLowerCase();
        if (name.indexOf("telegram") !== -1) return "#229ed9";
        if (name.indexOf("github") !== -1) return "#24292f";
        if (name.indexOf("spotify") !== -1) return "#1db954";
        if (name.indexOf("system") !== -1) return "#0a84ff";
        if (name.indexOf("slack") !== -1) return "#e01e5a";
        if (name.indexOf("news") !== -1) return "#ff375f";
        return "#0a84ff";
    }

    function getAppGlyph(appName) {
        let name = (appName || "").toLowerCase();
        if (name.indexOf("telegram") !== -1) return "󰀻";
        if (name.indexOf("github") !== -1) return "󰊤";
        if (name.indexOf("spotify") !== -1) return "󰓇";
        if (name.indexOf("system") !== -1) return "󰚰";
        if (name.indexOf("slack") !== -1) return "󰒱";
        return appName && appName.length > 0 ? appName.charAt(0).toUpperCase() : "󰂚";
    }

    // Unified Apple Banner Layout (Image 3 inspired)
    Row {
        id: bannerRow
        anchors.centerIn: parent
        spacing: 12

        // 1. Floating Circular Close Button (Image 3 inspired)
        Rectangle {
            id: closeCircle
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            radius: 10
            color: closeMouse.pressed ? Qt.rgba(255, 255, 255, 0.28)
                 : (closeMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.20) : Qt.rgba(255, 255, 255, 0.12))
            border.width: 1
            border.color: Qt.rgba(255, 255, 255, 0.15)

            Text {
                anchors.centerIn: parent
                text: "✕"
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
                color: closeMouse.containsMouse ? "#ffffff" : Theme.appleSubtext
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
                    if (root.notifService && root.currentNotif) {
                        root.notifService.dismiss(root.currentNotif.id);
                    }
                }
            }
        }

        // 2. Large Apple Squircle App Icon Badge (34x34 with 9px radius)
        Rectangle {
            id: appIconBadge
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            height: 34
            radius: 9
            color: root.currentNotif ? root.getAppColor(root.currentNotif.appName) : "#0a84ff"
            border.width: 1
            border.color: Qt.rgba(255, 255, 255, 0.18)
            antialiasing: true

            Text {
                anchors.centerIn: parent
                text: root.currentNotif ? root.getAppGlyph(root.currentNotif.appName) : "󰂚"
                font.family: Theme.iconFontFamily
                font.pixelSize: 18
                color: "#ffffff"
                renderType: Text.NativeRendering
            }
        }

        // 3. Two-Tier Apple Typography Column (Bold Title on Top, Subtitle Below)
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: 230
            spacing: 2

            // Line 1: Bold Title
            Text {
                width: parent.width
                text: root.currentNotif ? (root.currentNotif.summary || root.currentNotif.appName) : ""
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
                color: Theme.textPrimary
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            // Line 2: Message Body
            Text {
                width: parent.width
                text: root.currentNotif ? (root.currentNotif.body || root.currentNotif.summary) : ""
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.appleSubtext
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }
        }

        // 4. Right Action Pill Button / Queue Indicator (Image 3 inspired)
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            // Queue Counter Pill (if more than 1 alert queued)
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.queueCount > 0
                width: queueLabel.implicitWidth + 10
                height: 22
                radius: 11
                color: Qt.rgba(255, 255, 255, 0.16)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.18)

                Text {
                    id: queueLabel
                    anchors.centerIn: parent
                    text: "+" + root.queueCount
                    font.family: Theme.monoFontFamily
                    font.pixelSize: 11
                    font.bold: true
                    color: Theme.textPrimary
                    renderType: Text.NativeRendering
                }
            }

            // Translucent Action Pill ("View" / "Open")
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 52
                height: 24
                radius: 7
                color: viewMouse.pressed ? Qt.rgba(255, 255, 255, 0.24)
                     : (viewMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.18) : Qt.rgba(255, 255, 255, 0.11))
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.14)

                Text {
                    anchors.centerIn: parent
                    text: "View"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    color: Theme.textPrimary
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: viewMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    preventStealing: true
                    onClicked: (mouse) => {
                        mouse.accepted = true;
                        // Button click consumed, does NOT expand island
                    }
                }
            }
        }
    }
}
