import QtQuick 2.15
import "../../theme"
import "../../services"

Item {
    id: root

    property ClipboardService clipboardService: null

    readonly property string previewText: clipboardService ? clipboardService.copiedPreview : ""
    readonly property bool isImage: clipboardService ? clipboardService.isImage : false
    readonly property int triggerCount: clipboardService ? clipboardService.triggerCount : 0

    implicitHeight: 36
    implicitWidth: contentRow.implicitWidth + 20

    // Spring pop animation on trigger
    property real iconScale: 1.0

    onTriggerCountChanged: {
        iconScale = 1.35;
        springResetTimer.restart();
    }

    Timer {
        id: springResetTimer
        interval: 30
        repeat: false
        onTriggered: {
            root.iconScale = 1.0;
        }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 9

        // 1. SoftShell Glowing Emerald Badge with Pop Animation
        Rectangle {
            id: iconBadge
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            height: 22
            radius: 11
            color: Qt.rgba(48, 209, 88, 0.22)
            border.width: 1
            border.color: Qt.rgba(48, 209, 88, 0.50)
            antialiasing: true
            scale: root.iconScale

            Behavior on scale {
                SpringAnimation {
                    spring: 6.0
                    damping: 0.38
                    mass: 0.5
                }
            }

            Text {
                anchors.centerIn: parent
                text: root.isImage ? "󰋩" : "✓"
                font.family: root.isImage ? Theme.iconFontFamily : Theme.fontFamily
                font.pixelSize: root.isImage ? 12 : 11
                font.bold: true
                color: Theme.accentGreen
                renderType: Text.NativeRendering
            }
        }

        // 2. Action Label + Preview Snippet
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                text: "Copied"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                color: "#ffffff"
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "•"
                font.pixelSize: 9
                color: Qt.rgba(255, 255, 255, 0.35)
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.previewText
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.appleSubtext
                elide: Text.ElideRight
                maximumLineCount: 1
                width: Math.min(150, implicitWidth)
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
