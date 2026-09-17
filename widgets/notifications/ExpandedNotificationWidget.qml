import QtQuick 2.15
import "../../theme"
import "../../services"

Item {
    id: root

    property NotificationService notifService: null
    property int currentPage: 0
    readonly property int itemsPerPage: 3
    readonly property int totalCount: notifService ? notifService.totalCount : 0
    readonly property int pageCount: Math.max(1, Math.ceil(totalCount / itemsPerPage))

    // Automatically clamp current page when notifications are dismissed
    onTotalCountChanged: {
        if (root.currentPage >= root.pageCount) {
            root.currentPage = Math.max(0, root.pageCount - 1)
        }
    }

    implicitHeight: 246
    implicitWidth: 500

    // --- 1. 3-Card Stack Body ---
    Column {
        id: cardsColumn
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 6
        visible: root.totalCount > 0

        Repeater {
            model: root.notifService ? Math.min(root.itemsPerPage, Math.max(0, root.totalCount - root.currentPage * root.itemsPerPage)) : 0

            NotificationCard {
                id: card
                width: cardsColumn.width

                readonly property int itemIndex: root.currentPage * root.itemsPerPage + index
                readonly property var itemData: (root.notifService && itemIndex < root.notifService.history.count)
                                                ? root.notifService.history.get(itemIndex) : null

                notifId: itemData ? itemData.id : 0
                appName: itemData ? itemData.appName : ""
                summary: itemData ? itemData.summary : ""
                body: itemData ? itemData.body : ""
                timeStr: itemData ? itemData.timeStr : ""
                isPinned: itemData ? itemData.isPinned : false

                onPinClicked: {
                    if (root.notifService) root.notifService.togglePin(notifId)
                }

                onDismissClicked: {
                    if (root.notifService) root.notifService.dismiss(notifId)
                }
            }
        }
    }

    // --- 2. Empty State (When no notifications exist) ---
    Item {
        anchors.top: parent.top
        anchors.bottom: footerRow.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: root.totalCount === 0

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "󰂚"
                font.family: Theme.iconFontFamily
                font.pixelSize: 14
                color: Theme.textTertiary
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "No New Notifications"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.textTertiary
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
            }

            // Quick Simulate Button for easy testing
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: simText.implicitWidth + 10
                height: 18
                radius: 5
                antialiasing: true
                color: simTap.pressed ? Qt.rgba(255, 255, 255, 0.2)
                     : (simHover.hovered ? Qt.rgba(255, 255, 255, 0.12) : Qt.rgba(255, 255, 255, 0.06))

                Text {
                    id: simText
                    anchors.centerIn: parent
                    text: "+ Test Alert"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.accentBlue
                    renderType: Text.NativeRendering
                }

                HoverHandler { id: simHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    id: simTap
                    gesturePolicy: TapHandler.ReleaseWithinBounds
                    grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfSameType | PointerHandler.ApprovesTakeOverByNothing
                    onTapped: {
                        if (root.notifService) {
                            root.notifService.emitTestNotification()
                        }
                    }
                }
            }
        }
    }

    // --- 3. Footer Pagination & Actions Bar ---
    Item {
        id: footerRow
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 22

        // Left: Page Count + Clear All Action Pill
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.totalCount > 0 ? (root.currentPage * root.itemsPerPage + 1) + "-" + Math.min(root.totalCount, (root.currentPage + 1) * root.itemsPerPage) + " of " + root.totalCount : ""
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: Theme.textTertiary
                renderType: Text.NativeRendering
            }

            // "Clear All" Button (macOS frosted pill)
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: clearContent.implicitWidth + 14
                height: 20
                radius: 6
                antialiasing: true
                visible: root.totalCount > 0
                color: clearTap.pressed ? Qt.rgba(255, 255, 255, 0.22)
                     : (clearHover.hovered ? Qt.rgba(255, 255, 255, 0.14) : Qt.rgba(255, 255, 255, 0.08))
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.12)

                Behavior on color { ColorAnimation { duration: 120 } }

                Row {
                    id: clearContent
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        text: "Clear All"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        color: clearHover.hovered ? "#ffffff" : Theme.appleSubtext
                        renderType: Text.NativeRendering
                    }
                }

                HoverHandler {
                    id: clearHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    id: clearTap
                    gesturePolicy: TapHandler.ReleaseWithinBounds
                    grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfSameType | PointerHandler.ApprovesTakeOverByNothing
                    onTapped: {
                        if (root.notifService) {
                            root.notifService.clearAllUnpinned()
                        }
                    }
                }
            }
        }

        // Right Pagination (< • • • >)
        NotificationPagination {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            totalItems: root.totalCount
            itemsPerPage: root.itemsPerPage
            currentPage: root.currentPage
            visible: root.totalCount > 3
            onPageChanged: (page) => root.currentPage = page
        }
    }
}
