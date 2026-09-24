import QtQuick 2.15
import "../../theme"

// ClipboardHistoryRow — Single compact clipboard history entry:
// a type glyph plus an elided one-line preview, restored on click.
Item {
    id: root

    // 1. Component public interface
    property string preview: ""
    property bool isBinary: false
    signal clicked()

    // 2. Geometry & layout
    implicitWidth: parent ? parent.width : 280
    implicitHeight: 27

    // 3. Internal state
    readonly property string glyph: isBinary ? "󰋩" : "󰅍"
    readonly property string label: isBinary ? "Image" : preview

    // 6. Child elements
    Rectangle {
        anchors.fill: parent
        radius: 5
        color: rowHover.hovered ? Theme.barItemHover : "transparent"
        antialiasing: true
        Behavior on color { ColorAnimation { duration: 90 } }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 9

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.glyph
            font.family: Theme.iconFontFamily
            font.pixelSize: 13
            color: root.isBinary ? Theme.appleSubtext : "#ffffff"
            renderType: Text.NativeRendering
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 22
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: "#ffffff"
            elide: Text.ElideRight
            maximumLineCount: 1
            renderType: Text.NativeRendering
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
