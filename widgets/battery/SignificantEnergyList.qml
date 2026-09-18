import QtQuick 2.15
import Quickshell
import "../../theme"

// SignificantEnergyList — SoftShell list of apps consuming high energy
Column {
    id: root

    property var significantApps: []

    width: parent ? parent.width : 260
    spacing: 4

    readonly property bool hasApps: root.significantApps && root.significantApps.length > 0

    // Case A: No heavy apps detected
    Text {
        visible: !root.hasApps
        width: parent.width
        text: "No Apps Using Significant Energy"
        font.family: Theme.fontFamily
        font.pixelSize: 12
        color: Theme.textSecondary
        renderType: Text.NativeRendering
        topPadding: 2
        bottomPadding: 2
    }

    // Case B: Apps detected
    Column {
        visible: root.hasApps
        width: parent.width
        spacing: 3

        Text {
            text: "Using Significant Energy"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            color: Theme.textSecondary
            renderType: Text.NativeRendering
            bottomPadding: 2
        }

        Repeater {
            model: root.hasApps ? root.significantApps : []

            Item {
                width: parent.width
                height: 24

                Rectangle {
                    anchors.fill: parent
                    radius: 5
                    color: appHover.hovered ? Theme.barItemHover : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                        height: 16
                        source: (modelData.icon && typeof Quickshell !== "undefined" && Quickshell.iconPath)
                                ? Quickshell.iconPath(modelData.icon) : ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true

                        Rectangle {
                            anchors.fill: parent
                            visible: parent.status !== Image.Ready
                            radius: 8
                            color: Qt.rgba(255, 255, 255, 0.20)
                            border.color: Qt.rgba(255, 255, 255, 0.40)
                            border.width: 1
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: "#ffffff"
                        renderType: Text.NativeRendering
                    }
                }

                HoverHandler {
                    id: appHover
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
