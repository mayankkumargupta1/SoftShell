import QtQuick 2.15
import "../../theme"
import "../../services"

// SleepTimerSelector — Adjust display sleep and brightness dimming timeouts (SoftShell style)
Column {
    id: root

    property PowerService powerService: null

    width: parent ? parent.width : 280
    spacing: 10

    readonly property var sleepOptions: [
        { label: "2m",    sec: 120 },
        { label: "5m",    sec: 300 },
        { label: "10m",   sec: 600 },
        { label: "15m",   sec: 900 },
        { label: "30m",   sec: 1800 },
        { label: "Never", sec: 0 }
    ]

    // 1. Header Label
    Row {
        width: parent.width
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰌵"
            font.family: Theme.iconFontFamily
            font.pixelSize: 13
            color: Theme.textSecondary
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Turn display off after"
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: Theme.textPrimary
        }
    }

    // 2. Sleep Timeout Horizontal Pill Selector
    Rectangle {
        width: parent.width
        height: 28
        radius: 7
        color: Theme.popoverCardBg
        border.color: Theme.popoverBorder
        border.width: 1

        Row {
            anchors.fill: parent

            Repeater {
                model: root.sleepOptions

                Item {
                    id: optBtn
                    width: parent.width / root.sleepOptions.length
                    height: parent.height

                    readonly property bool isSelected: {
                        if (!root.powerService) return modelData.sec === 600;
                        return root.powerService.sleepTimeout === modelData.sec;
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: 5
                        color: optBtn.isSelected ? Qt.rgba(255, 255, 255, 0.20) : (optHover.hovered ? Qt.rgba(255, 255, 255, 0.06) : "transparent")
                        border.color: optBtn.isSelected ? Qt.rgba(255, 255, 255, 0.25) : "transparent"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: optBtn.isSelected ? Font.Medium : Font.Normal
                        color: optBtn.isSelected ? "#ffffff" : Theme.textSecondary
                    }

                    HoverHandler {
                        id: optHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            if (root.powerService) {
                                root.powerService.setSleepTimeout(modelData.sec);
                            }
                        }
                    }
                }
            }
        }
    }

    // 3. Dim Display Before Sleep Toggle Row
    Item {
        width: parent.width
        height: 26

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰃟"
                font.family: Theme.iconFontFamily
                font.pixelSize: 13
                color: Theme.textSecondary
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Slightly dim display before sleep"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.textSecondary
            }
        }

        // SoftShell Green Capsule Switch
        Rectangle {
            id: toggleSwitch
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            height: 18
            radius: 9

            readonly property bool isActive: root.powerService ? root.powerService.dimTimeout > 0 : true

            color: isActive ? "#34c759" : Qt.rgba(255, 255, 255, 0.18)
            Behavior on color { ColorAnimation { duration: 150 } }

            // Switch thumb
            Rectangle {
                x: toggleSwitch.isActive ? parent.width - width - 2 : 2
                anchors.verticalCenter: parent.verticalCenter
                width: 14
                height: 14
                radius: 7
                color: "#ffffff"

                Behavior on x {
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                }
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: {
                    if (root.powerService) {
                        let newDim = toggleSwitch.isActive ? 0 : 300;
                        root.powerService.setDimTimeout(newDim);
                    }
                }
            }
        }
    }
}
