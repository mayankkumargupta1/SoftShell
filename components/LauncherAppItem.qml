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

    // Active / Hover SoftShell Background Pill
    Rectangle {
        id: bg
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        radius: 10
        antialiasing: true
        color: root.isSelected ? Theme.launcherActiveBg : (mouseArea.containsMouse ? Theme.launcherItemHoverBg : "transparent")
        border.width: 1
        border.color: root.isSelected ? Theme.launcherActiveBorder : (mouseArea.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : "transparent")

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 120 }
        }

        // SoftShell Blue vertical accent pill on selected item
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 3
            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: 18
            radius: 1.5
            antialiasing: true
            color: Theme.accentBlue
            visible: root.isSelected
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: root.isSelected ? 16 : 12
        anchors.rightMargin: 12
        spacing: 11
        anchors.verticalCenter: parent.verticalCenter

        Behavior on anchors.leftMargin {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        // App Icon Container (SoftShell Squircle)
        Rectangle {
            id: iconBox
            width: 32
            height: 32
            radius: 8
            antialiasing: true
            anchors.verticalCenter: parent.verticalCenter
            color: root.app && root.app.isCommand ? Qt.rgba(48, 209, 88, 0.16) : (root.isSelected ? Qt.rgba(255, 255, 255, 0.12) : Qt.rgba(255, 255, 255, 0.08))
            border.color: root.app && root.app.isCommand ? Qt.rgba(48, 209, 88, 0.35) : Qt.rgba(255, 255, 255, 0.12)
            border.width: 1

            IconImage {
                id: appIcon
                visible: !root.app || !root.app.isCommand
                anchors.centerIn: parent
                implicitWidth: 20
                implicitHeight: 20
                source: (root.app && !root.app.isCommand && root.app.icon) ? Quickshell.iconPath(root.app.icon) : ""
            }

            // Command glyph or fallback icon glyph
            Text {
                anchors.centerIn: parent
                visible: (root.app && root.app.isCommand) || appIcon.status !== Image.Ready
                text: (root.app && root.app.iconGlyph) ? root.app.iconGlyph : "󰀻"
                color: (root.app && root.app.isCommand) ? Theme.accentGreen : (root.isSelected ? "#ffffff" : Theme.textSecondary)
                font.family: Theme.iconFontFamily
                font.pixelSize: 15
                renderType: Text.NativeRendering
            }
        }

        // Two-tier Typography Column
        Column {
            width: parent.width - iconBox.width - parent.spacing - (root.isSelected ? 64 : 0)
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                width: parent.width
                text: root.app ? root.app.name : ""
                color: "#ffffff"
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            Text {
                width: parent.width
                text: root.app && root.app.comment ? root.app.comment : (root.app && root.app.genericName ? root.app.genericName : (root.app && root.app.isCommand ? "Shell Command" : "Application"))
                color: root.isSelected ? Qt.rgba(255, 255, 255, 0.70) : Theme.appleSubtext
                font.family: Theme.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }
        }

        // Right-aligned Keycap Action Pill (SoftShell style)
        Row {
            visible: root.isSelected
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Open"
                color: Qt.rgba(255, 255, 255, 0.60)
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.weight: Font.Medium
                renderType: Text.NativeRendering
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 18
                radius: 4
                antialiasing: true
                color: Qt.rgba(255, 255, 255, 0.14)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.22)

                Text {
                    anchors.centerIn: parent
                    text: "↵"
                    color: "#ffffff"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    renderType: Text.NativeRendering
                }
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
