import QtQuick 2.15
import "../../theme"

// ProfileDropdownMenu — SoftShell-style popover selector with checkmark
Rectangle {
    id: root

    property string currentProfile: "balanced"
    signal profileSelected(string profile)

    implicitWidth: 130
    implicitHeight: menuCol.implicitHeight + 8
    radius: 7
    color: "#202024"
    border.color: Theme.popoverBorder
    border.width: 1

    readonly property var options: [
        { "id": "power-saver", "label": "Low Power" },
        { "id": "balanced",    "label": "Automatic" },
        { "id": "performance", "label": "High Power" }
    ]

    Column {
        id: menuCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 4
        spacing: 2

        Repeater {
            model: root.options

            Item {
                width: parent.width
                height: 24

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: itemArea.containsMouse ? "#007aff" : "transparent"
                    Behavior on color { ColorAnimation { duration: 80 } }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    // Checkmark
                    Text {
                        width: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.id === root.currentProfile ? "✓" : ""
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: "#ffffff"
                        renderType: Text.NativeRendering
                    }

                    // Label
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: "#ffffff"
                        renderType: Text.NativeRendering
                    }
                }

                MouseArea {
                    id: itemArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.profileSelected(modelData.id);
                    }
                }
            }
        }
    }
}
