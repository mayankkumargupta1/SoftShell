import QtQuick 2.15
import "../../theme"
import "../../services"

// DisplaySection — Monitor info and 60Hz / 120Hz refresh rate switcher
Item {
    id: root

    property ViewService service: null

    implicitWidth: parent ? parent.width : 304
    implicitHeight: col.implicitHeight

    Column {
        id: col
        width: parent.width
        spacing: 8

        // Section Header
        Item {
            width: parent.width
            height: 20

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "Display & Refresh Rate"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.appleHeaderMuted
                renderType: Text.NativeRendering
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: root.service ? (root.service.monitorWidth + "×" + root.service.monitorHeight) : ""
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.weight: Font.Medium
                color: Theme.appleSubtext
                renderType: Text.NativeRendering
            }
        }

        // Monitor Model / Output Summary
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 8
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰍹"
                font.family: Theme.iconFontFamily
                font.pixelSize: 14
                color: Theme.textPrimary
                renderType: Text.NativeRendering
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.service ? (root.service.monitorName + " (" + root.service.monitorDesc + ")") : "Internal Display"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Normal
                color: Theme.textSecondary
                renderType: Text.NativeRendering
            }
        }

        // Segmented Refresh Rate Pill
        Rectangle {
            id: segmentedPill
            width: parent.width
            height: 32
            radius: 8
            color: Theme.cardBg
            border.color: Theme.cardBorder
            border.width: 1
            antialiasing: true

            readonly property bool is120: root.service && root.service.refreshRate >= 100
            readonly property real segmentWidth: (width - 4) / 2

            // Animated Selection Sliding Pill
            Rectangle {
                id: indicator
                y: 2
                x: segmentedPill.is120 ? (segmentedPill.segmentWidth + 2) : 2
                width: segmentedPill.segmentWidth
                height: parent.height - 4
                radius: 6
                color: Theme.surfaceHover
                border.color: Qt.rgba(255, 255, 255, 0.18)
                border.width: 1
                antialiasing: true

                Behavior on x {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // 60 Hz Segment
            Item {
                id: seg60
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 2
                width: segmentedPill.segmentWidth

                Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "60 Hz"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: !segmentedPill.is120 ? Font.DemiBold : Font.Normal
                        color: !segmentedPill.is120 ? Theme.textPrimary : Theme.appleSubtext
                        renderType: Text.NativeRendering
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰂑"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 11
                        color: !segmentedPill.is120 ? Theme.accentGreen : Theme.appleSubtext
                        renderType: Text.NativeRendering
                    }
                }

                HoverHandler {
                    id: hover60
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        if (root.service) root.service.setRefreshRate(60);
                    }
                }
            }

            // 120 Hz Segment
            Item {
                id: seg120
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 2
                width: segmentedPill.segmentWidth

                Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "120 Hz"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: segmentedPill.is120 ? Font.DemiBold : Font.Normal
                        color: segmentedPill.is120 ? Theme.textPrimary : Theme.appleSubtext
                        renderType: Text.NativeRendering
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰓅"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 11
                        color: segmentedPill.is120 ? Theme.accentBlue : Theme.appleSubtext
                        renderType: Text.NativeRendering
                    }
                }

                HoverHandler {
                    id: hover120
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        if (root.service) root.service.setRefreshRate(120);
                    }
                }
            }
        }
    }
}
