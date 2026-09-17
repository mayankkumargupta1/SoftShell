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
    function getAppColor(name) {
        let n = (name || "").toLowerCase();
        if (n.indexOf("telegram") !== -1) return "#229ed9";
        if (n.indexOf("github") !== -1) return "#24292f";
        if (n.indexOf("spotify") !== -1) return "#1db954";
        if (n.indexOf("system") !== -1) return "#0a84ff";
        if (n.indexOf("slack") !== -1) return "#e01e5a";
        if (n.indexOf("news") !== -1) return "#ff375f";
        return "#0a84ff";
    }

    function getAppGlyph(name) {
        let n = (name || "").toLowerCase();
        if (n.indexOf("telegram") !== -1) return "󰀻";
        if (n.indexOf("github") !== -1) return "󰊤";
        if (n.indexOf("spotify") !== -1) return "󰓇";
        if (n.indexOf("system") !== -1) return "󰚰";
        if (n.indexOf("slack") !== -1) return "󰒱";
        return name && name.length > 0 ? name.charAt(0).toUpperCase() : "󰂚";
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
                    color: root.getAppColor(root.appName)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.2)

                    Text {
                        anchors.centerIn: parent
                        text: root.getAppGlyph(root.appName)
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
            text: root.summary.length > 0 ? root.summary : root.appName
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.bold: true
            color: Theme.textPrimary
            elide: Text.ElideRight
            renderType: Text.NativeRendering
        }

        // --- 3. Body Row: Message Preview ---
        Text {
            width: parent.width
            text: root.body.length > 0 ? root.body : root.summary
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: Theme.appleSubtext
            elide: Text.ElideRight
            renderType: Text.NativeRendering
        }
    }
}
