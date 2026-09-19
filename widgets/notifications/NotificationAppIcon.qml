import QtQuick 2.15
import "../../theme"

// NotificationAppIcon — Squircle app badge matching SoftShell notification design
Rectangle {
    id: root

    property string appName: ""
    property string summary: ""
    property string body: ""
    property string appIcon: ""

    implicitWidth: 38
    implicitHeight: 38
    radius: 10
    antialiasing: true

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
        if (n.indexOf("reminder") !== -1 || n.indexOf("calendar") !== -1) return "#ff9500";
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
        if (n.indexOf("reminder") !== -1 || n.indexOf("calendar") !== -1) return "󰄱";
        if (n.indexOf("system") !== -1) return "󰚰";
        return name && name.length > 0 ? name.charAt(0).toUpperCase() : "󰂚";
    }

    color: getAppColor(appName, summary, body)
    border.color: Qt.rgba(255, 255, 255, 0.18)
    border.width: 1

    // Render image icon if valid file path or URI provided
    Image {
        id: iconImg
        anchors.fill: parent
        anchors.margins: 4
        source: (root.appIcon && (root.appIcon.startsWith("/") || root.appIcon.startsWith("file://") || root.appIcon.startsWith("image://"))) ? root.appIcon : ""
        fillMode: Image.PreserveAspectFit
        visible: status === Image.Ready
        asynchronous: true
    }

    // High-contrast font glyph fallback
    Text {
        id: iconGlyph
        anchors.centerIn: parent
        visible: !iconImg.visible
        text: root.getAppGlyph(root.appName, root.summary, root.body)
        font.family: Theme.iconFontFamily
        font.pixelSize: 19
        color: "#ffffff"
        renderType: Text.NativeRendering
    }
}
