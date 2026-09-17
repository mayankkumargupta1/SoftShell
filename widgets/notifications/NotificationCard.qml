import QtQuick 2.15
import "../../theme"

Rectangle {
    id: root

    property int notifId: 0
    property string appName: "System"
    property string summary: ""
    property string body: ""
    property string timeStr: "Just now"
    property bool isPinned: false

    signal dismissClicked()
    signal pinClicked()

    implicitHeight: 68
    radius: Theme.cardRadius
    color: hoverHandler.hovered ? Theme.cardHover : Theme.cardBg
    border.color: root.isPinned ? Theme.cardBorderPinned : (hoverHandler.hovered ? Qt.rgba(255, 255, 255, 0.20) : Theme.cardBorder)
    border.width: 1
    antialiasing: true

    Behavior on color { ColorAnimation { duration: 140 } }
    Behavior on border.color { ColorAnimation { duration: 140 } }

    HoverHandler {
        id: hoverHandler
    }

    // App color helper
    function getAppColor(name, sum, body) {
        let n = ((name || "") + " " + (sum || "") + " " + (body || "")).toLowerCase();
        if (n.indexOf("whatsapp") !== -1) return "#25d366";
        if (n.indexOf("telegram") !== -1) return "#229ed9";
        if (n.indexOf("discord") !== -1) return "#5865f2";
        if (n.indexOf("github") !== -1) return "#24292f";
        if (n.indexOf("spotify") !== -1) return "#1db954";
        if (n.indexOf("slack") !== -1) return "#e01e5a";
        if (n.indexOf("brave") !== -1) return "#fb542b";
        if (n.indexOf("chrome") !== -1) return "#ea4335";
        if (n.indexOf("firefox") !== -1) return "#ff7139";
        if (n.indexOf("mail") !== -1 || n.indexOf("thunderbird") !== -1) return "#0a84ff";
        if (n.indexOf("system") !== -1) return "#0a84ff";
        if (n.indexOf("news") !== -1) return "#ff375f";
        return "#0a84ff";
    }

    function getAppGlyph(name, sum, body) {
        let n = ((name || "") + " " + (sum || "") + " " + (body || "")).toLowerCase();
        if (n.indexOf("whatsapp") !== -1) return "󰖣";
        if (n.indexOf("telegram") !== -1) return "󰀻";
        if (n.indexOf("discord") !== -1) return "󰙯";
        if (n.indexOf("github") !== -1) return "󰊤";
        if (n.indexOf("spotify") !== -1) return "󰓇";
        if (n.indexOf("slack") !== -1) return "󰒱";
        if (n.indexOf("brave") !== -1 || n.indexOf("chrome") !== -1 || n.indexOf("firefox") !== -1) return "󰖟";
        if (n.indexOf("mail") !== -1) return "󰇮";
        if (n.indexOf("system") !== -1) return "󰚰";
        return name && name.length > 0 ? name.charAt(0).toUpperCase() : "󰂚";
    }

    function cleanBody(b) {
        if (!b) return "";
        let lines = b.split(/[\r\n]+/).map(l => l.trim()).filter(l => l.length > 0);
        if (lines.length === 0) return "";
        if (lines.length === 1) return lines[0];
        if (lines[0].indexOf(".com") !== -1 || lines[0].indexOf(".org") !== -1 || lines[0].indexOf(".net") !== -1 || lines[0].indexOf("http") !== -1) {
            return lines.slice(1).join("\n");
        }
        return lines.join("\n");
    }

    Column {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 9
        anchors.bottomMargin: 9
        spacing: 4

        // --- 1. macOS Header Row: Micro Icon + All-Caps App Name ... Timestamp + Actions ---
        Item {
            width: parent.width
            height: 16

            // Left: Micro Squircle App Icon + Capitalized App Name
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 15
                    height: 15
                    radius: 4
                    color: root.getAppColor(root.appName, root.summary, root.body)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.2)

                    Text {
                        anchors.centerIn: parent
                        text: root.getAppGlyph(root.appName, root.summary, root.body)
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 9
                        color: "#ffffff"
                        renderType: Text.NativeRendering
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.appName.toUpperCase()
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.6
                    color: Theme.appleHeaderMuted
                    renderType: Text.NativeRendering
                }
            }

            // Right: Relative Timestamp + Pin & Close Controls
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.timeStr
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.appleHeaderMuted
                    renderType: Text.NativeRendering
                }

                // Pin Button Pill
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 18
                    height: 18
                    radius: 9
                    color: root.isPinned ? Qt.rgba(245, 166, 35, 0.20)
                         : (pinHover.hovered ? Qt.rgba(255, 255, 255, 0.15) : "transparent")

                    Text {
                        anchors.centerIn: parent
                        text: "󰤱"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 10
                        color: root.isPinned ? Theme.pinActive : (pinHover.hovered ? "#ffffff" : Theme.appleHeaderMuted)
                        renderType: Text.NativeRendering
                    }

                    HoverHandler { id: pinHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        gesturePolicy: TapHandler.ReleaseWithinBounds
                        grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfSameType | PointerHandler.ApprovesTakeOverByNothing
                        onTapped: root.pinClicked()
                    }
                }

                // Close Button Circle (macOS style)
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 18
                    height: 18
                    radius: 9
                    color: closeHover.hovered ? Qt.rgba(255, 55, 95, 0.25) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                        color: closeHover.hovered ? Theme.accentRed : Theme.appleHeaderMuted
                        renderType: Text.NativeRendering
                    }

                    HoverHandler { id: closeHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        gesturePolicy: TapHandler.ReleaseWithinBounds
                        grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfSameType | PointerHandler.ApprovesTakeOverByNothing
                        onTapped: root.dismissClicked()
                    }
                }
            }
        }

        // --- 2. Content Row: Bold Subject/Title ---
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

        // --- 3. Body Row: Message Preview ---
        Text {
            width: parent.width
            text: root.cleanBody(root.body.length > 0 ? root.body : root.summary)
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: Theme.appleSubtext
            maximumLineCount: 2
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            renderType: Text.NativeRendering
        }
    }
}
