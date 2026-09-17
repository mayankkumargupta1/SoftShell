import QtQuick 2.15
import "../../theme"
import "../../services"

Item {
    id: root

    property NotificationService notifService: null
    signal viewClicked()

    implicitHeight: 42
    implicitWidth: bannerRow.implicitWidth

    readonly property var currentNotif: notifService ? notifService.activeBanner : null
    readonly property int queueCount: notifService ? notifService.bannerQueueCount : 0

    // Authentic Apple app colors & Web App detection
    function getAppColor(appName, summary, body) {
        let text = ((appName || "") + " " + (summary || "") + " " + (body || "")).toLowerCase();
        if (text.indexOf("whatsapp") !== -1) return "#25d366";
        if (text.indexOf("telegram") !== -1) return "#229ed9";
        if (text.indexOf("discord") !== -1) return "#5865f2";
        if (text.indexOf("github") !== -1) return "#24292f";
        if (text.indexOf("spotify") !== -1) return "#1db954";
        if (text.indexOf("slack") !== -1) return "#e01e5a";
        if (text.indexOf("brave") !== -1) return "#fb542b";
        if (text.indexOf("chrome") !== -1) return "#ea4335";
        if (text.indexOf("firefox") !== -1) return "#ff7139";
        if (text.indexOf("mail") !== -1 || text.indexOf("thunderbird") !== -1) return "#0a84ff";
        if (text.indexOf("system") !== -1) return "#0a84ff";
        if (text.indexOf("news") !== -1) return "#ff375f";
        return "#0a84ff";
    }

    function getAppGlyph(appName, summary, body) {
        let text = ((appName || "") + " " + (summary || "") + " " + (body || "")).toLowerCase();
        if (text.indexOf("whatsapp") !== -1) return "󰖣";
        if (text.indexOf("telegram") !== -1) return "󰀻";
        if (text.indexOf("discord") !== -1) return "󰙯";
        if (text.indexOf("github") !== -1) return "󰊤";
        if (text.indexOf("spotify") !== -1) return "󰓇";
        if (text.indexOf("slack") !== -1) return "󰒱";
        if (text.indexOf("brave") !== -1 || text.indexOf("chrome") !== -1 || text.indexOf("firefox") !== -1) return "󰖟";
        if (text.indexOf("mail") !== -1) return "󰇮";
        if (text.indexOf("system") !== -1) return "󰚰";
        return appName && appName.length > 0 ? appName.charAt(0).toUpperCase() : "󰂚";
    }

    // Clean title and ensure single-line formatting
    function cleanTitle(notif) {
        if (!notif) return "";
        let t = (notif.summary || notif.appName || "").trim();
        return t.replace(/[\r\n]+/g, " ");
    }

    // Clean body: strip web domains (e.g. web.whatsapp.com) and convert multi-lines to clean single line
    function cleanBody(notif) {
        if (!notif) return "";
        let b = (notif.body || notif.summary || "").trim();
        if (!b) return "";
        let lines = b.split(/[\r\n]+/).map(l => l.trim()).filter(l => l.length > 0);
        if (lines.length === 0) return "";
        if (lines.length === 1) return lines[0];
        // If first line is a web origin (e.g. web.whatsapp.com, mail.google.com), prioritize the actual message line
        if (lines[0].indexOf(".com") !== -1 || lines[0].indexOf(".org") !== -1 || lines[0].indexOf(".net") !== -1 || lines[0].indexOf("http") !== -1) {
            return lines.slice(1).join(" • ");
        }
        return lines.join(" • ");
    }

    // Unified Apple Banner Layout
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
            color: root.currentNotif ? root.getAppColor(root.currentNotif.appName, root.currentNotif.summary, root.currentNotif.body) : "#0a84ff"
            border.width: 1
            border.color: Qt.rgba(255, 255, 255, 0.18)
            antialiasing: true

            Text {
                anchors.centerIn: parent
                text: root.currentNotif ? root.getAppGlyph(root.currentNotif.appName, root.currentNotif.summary, root.currentNotif.body) : "󰂚"
                font.family: Theme.iconFontFamily
                font.pixelSize: 18
                color: "#ffffff"
                renderType: Text.NativeRendering
            }
        }

        // 3. Two-Tier Apple Typography Column (Strict Single-Line per Tier)
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: 270
            spacing: 1
            clip: true

            // Line 1: Bold Title (Strictly 1 line, elided on right)
            Text {
                width: parent.width
                text: root.cleanTitle(root.currentNotif)
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                color: Theme.textPrimary
                maximumLineCount: 1
                elide: Text.ElideRight
                clip: true
                renderType: Text.NativeRendering
            }

            // Line 2: Message Body (Strictly 1 line, cleaned of origin prefixes, elided on right)
            Text {
                width: parent.width
                text: root.cleanBody(root.currentNotif)
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.appleSubtext
                maximumLineCount: 1
                elide: Text.ElideRight
                clip: true
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
                        root.viewClicked();
                    }
                }
            }
        }
    }
}
