import QtQuick 2.15
import Quickshell
import "../../theme"
import "../../services/popover"

// BarAppMenu — SoftShell left-side menu bar items:
// SoftShell logo | File | Edit | View | Go | Tools | Window | Help
Item {
    id: root

    implicitHeight: Theme.barHeight
    implicitWidth: menuRow.implicitWidth

    readonly property var menuItems: ["File", "Edit", "View", "Go", "Tools", "Window", "Help"]

    Row {
        id: menuRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        // 1. SoftShell Logo
        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 22

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: (logoTap.pressed || logoHover.hovered) ? Theme.barItemHover : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            // Subtle 1px drop shadow matching SoftShell Text.Raised styling
            Image {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1
                width: 16
                height: 16
                source: Qt.resolvedUrl("../../assets/softshell_icon_shadow.png")
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: 0.40
            }

            // Crisp white SoftShell logo
            Image {
                id: logoIcon
                anchors.centerIn: parent
                width: 16
                height: 16
                source: Qt.resolvedUrl("../../assets/softshell_icon.png")
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            HoverHandler {
                id: logoHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                id: logoTap
                onTapped: {
                    Quickshell.execDetached(["quickshell", "ipc", "call", "launcher", "toggle"]);
                }
            }
        }

        // 2. Menu Items (File, Edit, View, Go, Tools, Window, Help)
        Repeater {
            model: root.menuItems

            delegate: Item {
                required property string modelData

                anchors.verticalCenter: parent.verticalCenter
                width: menuText.implicitWidth + 16
                height: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: (itemTap.pressed || itemHover.hovered || (modelData === "File" && PopoverManager.activePopover === "file")) ? Theme.barItemHover : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                Text {
                    id: menuText
                    anchors.centerIn: parent
                    text: modelData
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Normal
                    color: Theme.barText
                    renderType: Text.NativeRendering
                }

                HoverHandler {
                    id: itemHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    id: itemTap
                    onTapped: {
                        if (modelData === "File") {
                            PopoverManager.toggle("file");
                        }
                    }
                }
            }
        }
    }
}
