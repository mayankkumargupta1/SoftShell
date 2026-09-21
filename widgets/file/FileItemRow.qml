import QtQuick 2.15
import "../../theme"

// FileItemRow — Reusable row for recent downloads in the File menu
Item {
    id: root

    property var fileData: null
    signal openClicked()
    signal revealClicked()

    implicitWidth: parent ? parent.width : 280
    implicitHeight: 38

    readonly property string fileName: (fileData && fileData.name) ? fileData.name : ""
    readonly property string sizeStr: (fileData && fileData.sizeStr) ? fileData.sizeStr : ""
    readonly property string timeStr: (fileData && fileData.timeStr) ? fileData.timeStr : ""
    readonly property string glyph: (fileData && fileData.glyph) ? fileData.glyph : "󰈔"

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 6
        color: rowHover.hovered ? Theme.barItemHover : "transparent"
        Behavior on color { ColorAnimation { duration: 90 } }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.right: revealBtn.left
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        // File Type Icon Badge
        Rectangle {
            width: 26
            height: 26
            radius: 5
            color: Qt.rgba(255, 255, 255, 0.08)
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: root.glyph
                font.family: Theme.iconFontFamily
                font.pixelSize: 14
                color: "#ffffff"
                renderType: Text.NativeRendering
            }
        }

        // File Name & Details
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 36
            spacing: 2

            Text {
                width: parent.width
                text: root.fileName
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                color: "#ffffff"
                elide: Text.ElideMiddle
                renderType: Text.NativeRendering
            }

            Text {
                width: parent.width
                text: root.sizeStr + " • " + root.timeStr
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: Theme.appleSubtext
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }
        }
    }

    // Reveal in File Manager action button (appears on hover)
    Item {
        id: revealBtn
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        opacity: (rowHover.hovered || revealHover.hovered) ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 100 } }

        Rectangle {
            anchors.fill: parent
            radius: 4
            color: revealHover.hovered ? Qt.rgba(255, 255, 255, 0.20) : "transparent"
        }

        Text {
            anchors.centerIn: parent
            text: "󰉋"
            font.family: Theme.iconFontFamily
            font.pixelSize: 13
            color: "#ffffff"
            renderType: Text.NativeRendering
        }

        HoverHandler {
            id: revealHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: root.revealClicked()
        }
    }

    HoverHandler {
        id: rowHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.openClicked()
    }
}
