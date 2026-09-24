import QtQuick 2.15
import "../../theme"
import "../../services"

// ClipboardHistorySection — Edit menu section listing the most recent
// clipboard entries; clicking one restores it, "Clear History" wipes them all.
Item {
    id: root

    // 1. Component public interface
    property ClipboardHistoryService service: null
    signal requestClose()

    // 2. Geometry & layout
    implicitWidth: parent ? parent.width : 300
    implicitHeight: col.implicitHeight

    // 3. Internal state
    readonly property int maxRows: 8
    readonly property var visibleEntries: service ? service.entries.slice(0, maxRows) : []
    readonly property bool unavailable: service ? !service.available : false
    readonly property bool isEmpty: service ? (service.loaded && service.count === 0) : false

    // 6. Child elements
    Column {
        id: col
        width: parent.width
        spacing: 1

        Repeater {
            model: root.visibleEntries

            delegate: ClipboardHistoryRow {
                required property var modelData

                preview: modelData.preview
                isBinary: modelData.isBinary
                onClicked: {
                    if (root.service) root.service.copyItem(modelData.id);
                    root.requestClose();
                }
            }
        }

        // Empty / unavailable placeholder
        Item {
            width: parent.width
            height: 24
            visible: root.unavailable || root.isEmpty

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: root.unavailable ? "Clipboard history unavailable" : "No clipboard history"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.appleSubtext
                renderType: Text.NativeRendering
            }
        }

        // Clear History link-style action (keeps the popover open so the
        // user sees the resulting empty state)
        Item {
            width: parent.width
            height: 24
            visible: root.visibleEntries.length > 0

            Item {
                id: clearBtn
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: clearLabel.implicitWidth + 10
                height: 20

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: clearHover.hovered ? Qt.rgba(255, 69, 58, 0.20) : "transparent"
                    antialiasing: true
                }

                Text {
                    id: clearLabel
                    anchors.centerIn: parent
                    text: "Clear History"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: clearHover.hovered ? "#ff453a" : "#007aff"
                    renderType: Text.NativeRendering
                }

                HoverHandler {
                    id: clearHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: if (root.service) root.service.clearHistory()
                }
            }
        }
    }
}
