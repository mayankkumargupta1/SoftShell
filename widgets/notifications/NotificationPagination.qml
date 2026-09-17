import QtQuick 2.15
import "../../theme"

Item {
    id: root

    property int totalItems: 0
    property int itemsPerPage: 3
    property int currentPage: 0

    signal pageChanged(int page)

    readonly property int pageCount: Math.max(1, Math.ceil(totalItems / itemsPerPage))

    implicitWidth: navRow.implicitWidth
    implicitHeight: 18

    Row {
        id: navRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        spacing: 6

        // 1. Previous Page Arrow
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            radius: 5
            antialiasing: true
            color: prevTap.pressed ? Qt.rgba(255, 255, 255, 0.2)
                 : (prevHover.hovered && root.currentPage > 0 ? Qt.rgba(255, 255, 255, 0.12) : "transparent")
            opacity: root.currentPage > 0 ? 1.0 : 0.25

            Text {
                anchors.centerIn: parent
                text: "◀"
                font.family: Theme.fontFamily
                font.pixelSize: 9
                color: root.currentPage > 0 ? Theme.textPrimary : Theme.textTertiary
                renderType: Text.NativeRendering
            }

            HoverHandler {
                id: prevHover
                cursorShape: root.currentPage > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            TapHandler {
                id: prevTap
                enabled: root.currentPage > 0
                gesturePolicy: TapHandler.ReleaseWithinBounds
                grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfSameType | PointerHandler.ApprovesTakeOverByNothing
                onTapped: {
                    if (root.currentPage > 0) {
                        root.currentPage--
                        root.pageChanged(root.currentPage)
                    }
                }
            }
        }

        // 2. Interactive Page Dots
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            Repeater {
                model: root.pageCount

                Rectangle {
                    id: dot
                    anchors.verticalCenter: parent.verticalCenter
                    width: index === root.currentPage ? 14 : 5
                    height: 5
                    radius: 2.5
                    antialiasing: true
                    color: index === root.currentPage ? Theme.textPrimary : Qt.rgba(255, 255, 255, 0.25)

                    Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
                    Behavior on color { ColorAnimation { duration: 180 } }

                    HoverHandler {
                        id: dotHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        gesturePolicy: TapHandler.ReleaseWithinBounds
                        grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfSameType | PointerHandler.ApprovesTakeOverByNothing
                        onTapped: {
                            root.currentPage = index
                            root.pageChanged(index)
                        }
                    }
                }
            }
        }

        // 3. Next Page Arrow
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            radius: 5
            antialiasing: true
            color: nextTap.pressed ? Qt.rgba(255, 255, 255, 0.2)
                 : (nextHover.hovered && root.currentPage < root.pageCount - 1 ? Qt.rgba(255, 255, 255, 0.12) : "transparent")
            opacity: root.currentPage < root.pageCount - 1 ? 1.0 : 0.25

            Text {
                anchors.centerIn: parent
                text: "▶"
                font.family: Theme.fontFamily
                font.pixelSize: 9
                color: root.currentPage < root.pageCount - 1 ? Theme.textPrimary : Theme.textTertiary
                renderType: Text.NativeRendering
            }

            HoverHandler {
                id: nextHover
                cursorShape: root.currentPage < root.pageCount - 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            TapHandler {
                id: nextTap
                enabled: root.currentPage < root.pageCount - 1
                gesturePolicy: TapHandler.ReleaseWithinBounds
                grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfSameType | PointerHandler.ApprovesTakeOverByNothing
                onTapped: {
                    if (root.currentPage < root.pageCount - 1) {
                        root.currentPage++
                        root.pageChanged(root.currentPage)
                    }
                }
            }
        }
    }
}
