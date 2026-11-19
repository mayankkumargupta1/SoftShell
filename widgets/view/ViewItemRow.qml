import QtQuick 2.15
import "../../theme"

// ViewItemRow — Action row for window presentation toggles in ViewCard
Item {
    id: root

    property string glyph: ""
    property string title: ""
    property string shortcut: ""
    property bool active: false
    property color activeColor: Theme.accentBlue

    signal clicked()

    implicitWidth: parent ? parent.width : 304
    implicitHeight: 30

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 6
        antialiasing: true
        color: rowTap.pressed ? Theme.surfaceActive : (rowHover.hovered ? Theme.barItemHover : "transparent")
        Behavior on color { ColorAnimation { duration: 90 } }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.glyph
            font.family: Theme.iconFontFamily
            font.pixelSize: 14
            color: root.active ? root.activeColor : Theme.textPrimary
            renderType: Text.NativeRendering
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.title
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Normal
            color: Theme.textPrimary
            renderType: Text.NativeRendering
        }
    }

    // Right elements: Shortcut and Active State Pill
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Keyboard Shortcut Badge
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.shortcut !== ""
            text: root.shortcut
            font.family: Theme.monoFontFamily
            font.pixelSize: 10
            font.weight: Font.Normal
            color: Theme.appleSubtext
            renderType: Text.NativeRendering
        }

        // Active State Indicator Dot/Pill
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: root.active ? 8 : 0
            height: 8
            radius: 4
            color: root.activeColor
            antialiasing: true
            opacity: root.active ? 1 : 0

            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }

    HoverHandler {
        id: rowHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: rowTap
        onTapped: root.clicked()
    }
}
