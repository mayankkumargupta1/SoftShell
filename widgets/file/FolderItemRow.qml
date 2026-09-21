import QtQuick 2.15
import "../../theme"

// FolderItemRow — Row for bookmarked folders in the File menu
Item {
    id: root

    property var folderData: null
    signal clicked()

    implicitWidth: parent ? parent.width : 280
    implicitHeight: 28

    readonly property string folderName: (folderData && folderData.name) ? folderData.name : ""
    readonly property string glyph: (folderData && folderData.glyph) ? folderData.glyph : "󰉋"

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
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.glyph
            font.family: Theme.iconFontFamily
            font.pixelSize: 15
            color: "#ffffff"
            renderType: Text.NativeRendering
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 30
            text: root.folderName
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Normal
            color: "#ffffff"
            elide: Text.ElideRight
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
