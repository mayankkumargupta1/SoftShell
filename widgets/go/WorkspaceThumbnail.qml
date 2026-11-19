import QtQuick 2.15
import "../../theme"

// WorkspaceThumbnail — Scaled miniature monitor rendering live window wireframes
Item {
    id: root

    property var windows: []
    property bool isActive: false
    property real screenWidth: 1440.0
    property real screenHeight: 900.0

    implicitWidth: 116
    implicitHeight: 72

    readonly property real scaleX: width / screenWidth
    readonly property real scaleY: height / screenHeight

    // Outer miniature monitor frame
    Rectangle {
        id: monitorFrame
        anchors.fill: parent
        radius: 6
        color: Theme.surfaceBg
        border.color: root.isActive ? Theme.accentBlue : Theme.cardBorder
        border.width: root.isActive ? 2 : 1
        antialiasing: true
        clip: true

        // Background wallpaper-like tint
        Rectangle {
            anchors.fill: parent
            radius: 5
            color: root.isActive ? Qt.rgba(10, 132, 255, 0.08) : "transparent"
        }

        // Empty state placeholder
        Text {
            anchors.centerIn: parent
            visible: !root.windows || root.windows.length === 0
            text: "󰍹"
            font.family: Theme.iconFontFamily
            font.pixelSize: 18
            color: Theme.appleSubtext
            opacity: 0.35
            renderType: Text.NativeRendering
        }

        // Scaled window wireframes
        Repeater {
            model: root.windows || []
            delegate: Rectangle {
                id: winRect
                required property var modelData

                x: Math.max(1, Math.round(modelData.x * root.scaleX))
                y: Math.max(1, Math.round(modelData.y * root.scaleY))
                width: Math.max(10, Math.min(root.width - x - 1, Math.round(modelData.width * root.scaleX)))
                height: Math.max(10, Math.min(root.height - y - 1, Math.round(modelData.height * root.scaleY)))

                radius: 3
                color: Qt.rgba(255, 255, 255, 0.14)
                border.color: Qt.rgba(255, 255, 255, 0.28)
                border.width: 1
                antialiasing: true

                // Centered application glyph inside miniature window
                Text {
                    anchors.centerIn: parent
                    text: winRect.modelData.glyph || "󰈔"
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Math.max(8, Math.min(11, Math.min(parent.width - 2, parent.height - 2)))
                    color: "#ffffff"
                    visible: parent.width >= 10 && parent.height >= 10
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
