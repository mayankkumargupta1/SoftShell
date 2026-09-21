import QtQuick 2.15
import "../../theme"

// TrashRow — Trash row with count and quick empty action
Item {
    id: root

    property int count: 0
    property string text: "Empty"
    property string glyph: "󰩺"
    signal clicked()
    signal emptyClicked()

    implicitWidth: parent ? parent.width : 280
    implicitHeight: 32

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 5
        color: rowHover.hovered ? Theme.barItemHover : "transparent"
        Behavior on color { ColorAnimation { duration: 90 } }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: emptyBtn.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.glyph
            font.family: Theme.iconFontFamily
            font.pixelSize: 15
            color: root.count > 0 ? "#ffffff" : Theme.appleSubtext
            renderType: Text.NativeRendering
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Trash"
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Normal
            color: "#ffffff"
            renderType: Text.NativeRendering
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "(" + root.text + ")"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: Theme.appleSubtext
            renderType: Text.NativeRendering
        }
    }

    // Empty Trash action link
    Item {
        id: emptyBtn
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: emptyLabel.implicitWidth + 8
        height: 20
        visible: root.count > 0

        Rectangle {
            anchors.fill: parent
            radius: 4
            color: emptyHover.hovered ? Qt.rgba(255, 69, 58, 0.20) : "transparent"
        }

        Text {
            id: emptyLabel
            anchors.centerIn: parent
            text: "Empty"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            color: emptyHover.hovered ? "#ff453a" : "#007aff"
            renderType: Text.NativeRendering
        }

        HoverHandler {
            id: emptyHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: root.emptyClicked()
        }
    }

    HoverHandler {
        id: rowHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
