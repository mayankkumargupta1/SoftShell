import QtQuick 2.15
import "../../theme"

Item {
    id: root

    property string iconText: "▶"
    property int iconPixelSize: 13
    property color iconColor: "#ffffff"
    property real cornerRadius: 8
    property int iconOffsetX: 0
    property int iconOffsetY: 0
    property string iconFontFamily: Theme.iconFontFamily
    signal clicked()

    implicitWidth: 28
    implicitHeight: 28

    // Interactive state
    readonly property bool isHovered: hoverHandler.hovered
    readonly property bool isPressed: tapHandler.pressed

    scale: isPressed ? 0.90 : (isHovered ? 1.04 : 1.0)

    Behavior on scale {
        SpringAnimation {
            spring: 5.5
            damping: 0.4
            mass: 0.6
        }
    }

    // Glassmorphic translucent background
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.isPressed ? Qt.rgba(1, 1, 1, 0.24)
             : (root.isHovered ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.09))
        border.color: root.isHovered ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(1, 1, 1, 0.08)
        border.width: 1
        antialiasing: true

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 120 }
        }

        Text {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.iconOffsetX
            anchors.verticalCenterOffset: root.iconOffsetY
            text: root.iconText
            font.family: root.iconFontFamily
            font.pixelSize: root.iconPixelSize
            color: root.iconColor
            renderType: Text.NativeRendering
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tapHandler
        gesturePolicy: TapHandler.ReleaseWithinBounds
        grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfSameType | PointerHandler.ApprovesTakeOverByNothing
        onTapped: root.clicked()
    }
}
