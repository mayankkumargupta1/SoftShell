import QtQuick 2.15
import "../../theme"
import "../../services"

// AppearanceSection — Edit popover content for regenerating the accent palette
// from the current wallpaper, with live status and swatch preview (no header).
Item {
    id: root

    // 1. Public interface
    signal requestClose()

    // 2. Geometry & Layout
    implicitHeight: col.implicitHeight

    // 3. Internal state
    readonly property ThemeGenService _themeGen: ThemeGenService {}
    readonly property string _status: root._themeGen.generating
        ? "Generating…"
        : (root._themeGen.failed
            ? "Could not generate theme"
            : (root._themeGen.available ? "Palette ready" : "Not generated yet"))

    // 6. Child Elements / Visual Tree
    Column {
        id: col
        width: root.width
        spacing: 6

        // Action + status. The popover stays open so the result stays visible.
        Item {
            width: parent.width
            height: 22

            Item {
                id: applyBtn
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                width: applyLabel.implicitWidth + 12
                height: 20
                opacity: root._themeGen.generating ? 0.5 : 1.0

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    antialiasing: true
                    color: applyHover.hovered ? Theme.barItemHover : "transparent"
                    Behavior on color { ColorAnimation { duration: 90 } }
                }

                Text {
                    id: applyLabel
                    anchors.centerIn: parent
                    text: "Apply theme from wallpaper"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: "#007aff"
                    renderType: Text.NativeRendering
                }

                HoverHandler {
                    id: applyHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    enabled: !root._themeGen.generating
                    onTapped: root._themeGen.regenerate()
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: root._status
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: Theme.appleSubtext
                renderType: Text.NativeRendering
            }
        }

        // Swatch preview of the generated accents
        Row {
            leftPadding: 6
            spacing: 6
            visible: root._themeGen.available

            Repeater {
                model: [
                    root._themeGen.accent,
                    root._themeGen.accentAlt,
                    root._themeGen.surface
                ]
                delegate: Rectangle {
                    width: 16
                    height: 16
                    radius: 3
                    antialiasing: true
                    color: modelData
                    border.width: 1
                    border.color: Theme.popoverSeparator
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }
            }
        }
    }
}
