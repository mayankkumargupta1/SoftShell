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
            color: prevMouse.pressed ? Qt.rgba(255, 255, 255, 0.2)
                 : (prevMouse.containsMouse && root.currentPage > 0 ? Qt.rgba(255, 255, 255, 0.12) : "transparent")
            opacity: root.currentPage > 0 ? 1.0 : 0.25

            Text {
                anchors.centerIn: parent
                text: "◀"
                font.family: Theme.fontFamily
                font.pixelSize: 9
                color: root.currentPage > 0 ? Theme.textPrimary : Theme.textTertiary
                renderType: Text.NativeRendering
            }

            MouseArea {
                id: prevMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: root.currentPage > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                preventStealing: true
                enabled: root.currentPage > 0
                onClicked: (mouse) => {
                    mouse.accepted = true;
                    if (root.currentPage > 0) {
                        root.currentPage--;
                        root.pageChanged(root.currentPage);
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

                    MouseArea {
                        id: dotMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        preventStealing: true
                        onClicked: (mouse) => {
                            mouse.accepted = true;
                            root.currentPage = index;
                            root.pageChanged(index);
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
            color: nextMouse.pressed ? Qt.rgba(255, 255, 255, 0.2)
                 : (nextMouse.containsMouse && root.currentPage < root.pageCount - 1 ? Qt.rgba(255, 255, 255, 0.12) : "transparent")
            opacity: root.currentPage < root.pageCount - 1 ? 1.0 : 0.25

            Text {
                anchors.centerIn: parent
                text: "▶"
                font.family: Theme.fontFamily
                font.pixelSize: 9
                color: root.currentPage < root.pageCount - 1 ? Theme.textPrimary : Theme.textTertiary
                renderType: Text.NativeRendering
            }

            MouseArea {
                id: nextMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: root.currentPage < root.pageCount - 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                preventStealing: true
                enabled: root.currentPage < root.pageCount - 1
                onClicked: (mouse) => {
                    mouse.accepted = true;
                    if (root.currentPage < root.pageCount - 1) {
                        root.currentPage++;
                        root.pageChanged(root.currentPage);
                    }
                }
            }
        }
    }
}
