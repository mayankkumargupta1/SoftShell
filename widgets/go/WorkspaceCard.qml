import QtQuick 2.15
import "../../theme"

// WorkspaceCard — Interactive preview card for one desktop workspace
Item {
    id: root

    property int wsId: 1
    property bool isActive: false
    property var windows: []
    property string summary: "Empty"
    property real screenWidth: 1440.0
    property real screenHeight: 900.0

    signal clicked()

    implicitWidth: 128
    implicitHeight: 124

    scale: cardTap.pressed ? 0.95 : (cardHover.hovered ? 1.04 : 1.0)
    Behavior on scale {
        SpringAnimation {
            spring: 5.0
            damping: 0.4
            mass: 0.6
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 10
        color: cardHover.hovered ? Theme.barItemHover : (root.isActive ? Qt.rgba(255, 255, 255, 0.08) : Theme.cardBg)
        border.color: root.isActive ? Theme.accentBlue : (cardHover.hovered ? Qt.rgba(255, 255, 255, 0.22) : Theme.cardBorder)
        border.width: root.isActive ? 2 : 1
        antialiasing: true

        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }

        Column {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 5

            // 1. Workspace Header
            Item {
                width: parent.width
                height: 14

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Workspace " + root.wsId
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.weight: root.isActive ? Font.Bold : Font.DemiBold
                    color: root.isActive ? Theme.accentBlue : Theme.textPrimary
                    renderType: Text.NativeRendering
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 6
                    height: 6
                    radius: 3
                    color: Theme.statGreen
                    visible: root.isActive
                    antialiasing: true
                }
            }

            // 2. Miniature Desktop Preview
            WorkspaceThumbnail {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 70
                windows: root.windows
                isActive: root.isActive
                screenWidth: root.screenWidth
                screenHeight: root.screenHeight
            }

            // 3. Application Summary Footer
            Text {
                width: parent.width
                text: root.summary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.weight: Font.Normal
                color: root.summary === "Empty" ? Theme.appleSubtext : Theme.textSecondary
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
            }
        }
    }

    HoverHandler {
        id: cardHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: cardTap
        onTapped: root.clicked()
    }
}
