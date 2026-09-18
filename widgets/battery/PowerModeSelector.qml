import QtQuick 2.15
import "../../theme"
import "../../services"

// PowerModeSelector — SoftShell Segmented Control for Performance / Balanced / Low Power
Item {
    id: root

    property PowerService powerService: null

    implicitWidth: parent ? parent.width : 280
    implicitHeight: 34

    readonly property var modes: [
        { id: "performance", label: "Performance", icon: "󰓅" },
        { id: "balanced",    label: "Balanced",    icon: "󰗑" },
        { id: "power-saver", label: "Low Power",   icon: "󰌪" }
    ]

    // Container background capsule
    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Theme.popoverCardBg
        border.color: Theme.popoverBorder
        border.width: 1

        // Active Segment Highlight Pill
        Rectangle {
            id: activeIndicator
            readonly property int activeIdx: {
                if (!root.powerService) return 1;
                let cur = root.powerService.currentProfile;
                if (cur === "performance") return 0;
                if (cur === "power-saver") return 2;
                return 1;
            }

            x: activeIdx * (parent.width / 3) + 2
            y: 2
            width: (parent.width / 3) - 4
            height: parent.height - 4
            radius: 6
            color: {
                if (activeIdx === 0) return Qt.rgba(255, 159, 10, 0.35); // Performance amber
                if (activeIdx === 2) return Qt.rgba(48, 209, 88, 0.35);  // Low Power green
                return Qt.rgba(255, 255, 255, 0.20);                     // Balanced white
            }
            border.color: {
                if (activeIdx === 0) return Qt.rgba(255, 159, 10, 0.60);
                if (activeIdx === 2) return Qt.rgba(48, 209, 88, 0.60);
                return Qt.rgba(255, 255, 255, 0.30);
            }
            border.width: 1

            Behavior on x {
                SpringAnimation { spring: 3.5; damping: 0.32; mass: 0.8 }
            }
            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }
        }

        // 3 Segment Buttons
        Row {
            anchors.fill: parent

            Repeater {
                model: root.modes

                Item {
                    id: btn
                    width: parent.width / 3
                    height: parent.height

                    readonly property bool isSelected: {
                        if (!root.powerService) return index === 1;
                        return root.powerService.currentProfile === modelData.id;
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.icon
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 12
                            color: btn.isSelected ? "#ffffff" : Theme.textSecondary
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.label
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: btn.isSelected ? Font.Medium : Font.Normal
                            color: btn.isSelected ? "#ffffff" : Theme.textSecondary
                        }
                    }

                    HoverHandler {
                        id: hover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            if (root.powerService) {
                                root.powerService.setProfile(modelData.id);
                            }
                        }
                    }
                }
            }
        }
    }
}
