import QtQuick 2.15
import "../../theme"
import "../../services"
import "../../services/popover"

// GoCard — Horizontally thick carousel showing 5 workspaces at once
// with interactive miniature previews and left/right navigation arrows.
Rectangle {
    id: root

    property WorkspaceNavService service: null

    implicitWidth: 746
    implicitHeight: 164

    radius: Theme.popoverRadius
    color: Theme.popoverBg
    border.color: Theme.popoverBorder
    border.width: 1
    antialiasing: true

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // 1. Header Bar: Title + Page Indicator Dots
        Item {
            width: parent.width
            height: 16

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                text: "Go to Workspace"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.appleHeaderMuted
                renderType: Text.NativeRendering
            }

            // Paging indicator (1–5 / 6–10)
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.service && root.service.currentPage === 1 ? "6 – 10" : "1 – 5"
                    font.family: Theme.monoFontFamily
                    font.pixelSize: 10
                    color: Theme.appleSubtext
                    renderType: Text.NativeRendering
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 5
                    height: 5
                    radius: 2.5
                    color: root.service && root.service.currentPage === 0 ? Theme.accentBlue : Theme.cardBorder
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 5
                    height: 5
                    radius: 2.5
                    color: root.service && root.service.currentPage === 1 ? Theme.accentBlue : Theme.cardBorder
                }
            }
        }

        // 2. Carousel Row: [ < Button ] [ 5 Workspace Cards ] [ > Button ]
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            // Left Navigation Button (<)
            Item {
                width: 26
                height: 124
                anchors.verticalCenter: parent.verticalCenter
                opacity: root.service && root.service.currentPage > 0 ? 1.0 : 0.25

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: prevHover.hovered && (root.service && root.service.currentPage > 0) ? Theme.barItemHover : "transparent"
                    border.color: Theme.cardBorder
                    border.width: 1
                    antialiasing: true
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰅁"
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 16
                    color: Theme.textPrimary
                    renderType: Text.NativeRendering
                }

                HoverHandler {
                    id: prevHover
                    cursorShape: (root.service && root.service.currentPage > 0) ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

                TapHandler {
                    enabled: root.service && root.service.currentPage > 0
                    onTapped: if (root.service) root.service.prevPage()
                }
            }

            // 5 Workspaces Cards Row
            Row {
                id: cardsRow
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: root.service && root.service.currentPage === 1 ? [6, 7, 8, 9, 10] : [1, 2, 3, 4, 5]

                    delegate: WorkspaceCard {
                        id: cardItem
                        required property int modelData

                        wsId: modelData
                        isActive: root.service ? (root.service.activeWorkspaceId === modelData) : false
                        windows: root.service && root.service.windowsByWorkspace ? (root.service.windowsByWorkspace[modelData.toString()] || []) : []
                        summary: root.service && root.service.appSummaryByWorkspace ? (root.service.appSummaryByWorkspace[modelData.toString()] || "Empty") : "Empty"
                        screenWidth: root.service ? root.service.screenWidth : 1440.0
                        screenHeight: root.service ? root.service.screenHeight : 900.0

                        onClicked: {
                            if (root.service) root.service.goToWorkspace(cardItem.wsId);
                            PopoverManager.close("go");
                        }
                    }
                }
            }

            // Right Navigation Button (>)
            Item {
                width: 26
                height: 124
                anchors.verticalCenter: parent.verticalCenter
                opacity: root.service && root.service.currentPage < 1 ? 1.0 : 0.25

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: nextHover.hovered && (root.service && root.service.currentPage < 1) ? Theme.barItemHover : "transparent"
                    border.color: Theme.cardBorder
                    border.width: 1
                    antialiasing: true
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰅂"
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 16
                    color: Theme.textPrimary
                    renderType: Text.NativeRendering
                }

                HoverHandler {
                    id: nextHover
                    cursorShape: (root.service && root.service.currentPage < 1) ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

                TapHandler {
                    enabled: root.service && root.service.currentPage < 1
                    onTapped: if (root.service) root.service.nextPage()
                }
            }
        }
    }
}
