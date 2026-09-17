import QtQuick 2.15
import "../theme"

Item {
    id: root

    // Public properties
    property string text: ""
    property string iconText: ""
    property color iconColor: Theme.textPrimary
    property int iconSize: 16
    property color bgColor: "transparent"
    property color hoverBgColor: Theme.surfaceHover
    property color pressedBgColor: Theme.surfaceActive
    property int radius: width / 2
    property bool active: false

    signal clicked()

    implicitWidth: 32
    implicitHeight: 32

    scale: tapHandler.pressed ? 0.88 : (hoverHandler.hovered ? 1.08 : 1.0)
    Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuad } }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.radius
        antialiasing: true
        color: tapHandler.pressed ? root.pressedBgColor : (hoverHandler.hovered ? root.hoverBgColor : root.bgColor)
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    Text {
        id: iconLabel
        anchors.centerIn: parent
        text: root.iconText !== "" ? root.iconText : root.text
        color: root.iconColor
        font.pixelSize: root.iconSize
        font.family: Theme.fontFamily
        renderType: Text.NativeRendering
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tapHandler
        onTapped: root.clicked()
    }
}
