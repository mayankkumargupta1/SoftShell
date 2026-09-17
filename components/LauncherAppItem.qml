import QtQuick 2.15
import Quickshell
import Quickshell.Widgets
import "../theme"

Item {
    id: root

    property var app: null
    property bool isSelected: false
    signal clicked()
    signal hovered()

    implicitWidth: parent ? parent.width : (Theme.launcherWidth - (Theme.launcherFillet * 2) - 20)
    implicitHeight: Theme.launcherItemHeight

    // Active / Hover Apple Background Pill
    Rectangle {
        id: bg
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: 2
        radius: 9
        color: root.isSelected ? Theme.launcherActiveBg : (mouseArea.containsMouse ? Theme.launcherItemHoverBg : "transparent")

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter

        // App Icon Container (Apple Squircle)
        Rectangle {
            id: iconBox
            width: 28
            height: 28
            radius: 7
            anchors.verticalCenter: parent.verticalCenter
            color: root.isSelected ? Qt.rgba(255, 255, 255, 0.18) : (root.app && root.app.isCommand ? Qt.rgba(48, 209, 88, 0.15) : Qt.rgba(255, 255, 255, 0.08))
            border.color: root.app && root.app.isCommand ? Qt.rgba(48, 209, 88, 0.35) : Qt.rgba(255, 255, 255, 0.12)
            border.width: 1

            IconImage {
                id: appIcon
                visible: !root.app || !root.app.isCommand
                anchors.centerIn: parent
                implicitWidth: 18
                implicitHeight: 18
                source: (root.app && !root.app.isCommand && root.app.icon) ? Quickshell.iconPath(root.app.icon) : ""
            }

            // Command glyph or fallback icon glyph
            Text {
                anchors.centerIn: parent
                visible: (root.app && root.app.isCommand) || appIcon.status !== Image.Ready
                text: (root.app && root.app.iconGlyph) ? root.app.iconGlyph : "󰀻"
                color: (root.app && root.app.isCommand) ? Theme.accentGreen : (root.isSelected ? "#ffffff" : Theme.textSecondary)
                font.family: Theme.iconFontFamily
                font.pixelSize: 14
            }
        }

        // Two-tier Typography Column
        Column {
            width: parent.width - iconBox.width - parent.spacing - (root.isSelected ? 32 : 0)
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                width: parent.width
                text: root.app ? root.app.name : ""
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.app && root.app.comment ? root.app.comment : (root.app && root.app.genericName ? root.app.genericName : (root.app && root.app.isCommand ? "Shell Command" : "Application"))
                color: root.isSelected ? Qt.rgba(255, 255, 255, 0.78) : Theme.appleSubtext
                font.family: Theme.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        // Right-aligned Enter indicator when selected
        Rectangle {
            visible: root.isSelected
            width: 20
            height: 18
            radius: 5
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.rgba(255, 255, 255, 0.22)

            Text {
                anchors.centerIn: parent
                text: "↵"
                color: "#ffffff"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onEntered: root.hovered()
    }
}
