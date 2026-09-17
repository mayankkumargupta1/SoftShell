import QtQuick 2.15
import "../theme"

Rectangle {
    id: root

    property string text: ""
    readonly property bool isCommandMode: text.trim().startsWith(">")

    onTextChanged: {
        if (input.text !== text) {
            input.text = text;
        }
    }

    signal navigateUp()
    signal navigateDown()
    signal activate()
    signal dismiss()
    signal queryChanged(string query)

    implicitWidth: parent ? parent.width : (Theme.launcherWidth - (Theme.launcherFillet * 2) - 20)
    implicitHeight: Theme.launcherInputHeight
    radius: 12
    antialiasing: true
    color: Theme.launcherInputBg
    border.color: root.isCommandMode ? Theme.accentGreen : (input.activeFocus ? Qt.rgba(10, 132, 255, 0.50) : Theme.launcherInputBorder)
    border.width: 1

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter

        // Prefix Icon / Mode Badge
        Rectangle {
            id: badge
            anchors.verticalCenter: parent.verticalCenter
            height: 22
            radius: 6
            antialiasing: true
            visible: root.isCommandMode
            width: modeRow.implicitWidth + 10
            color: Qt.rgba(48, 209, 88, 0.16)
            border.color: Qt.rgba(48, 209, 88, 0.45)
            border.width: 1

            Row {
                id: modeRow
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: ""
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 11
                    color: Theme.accentGreen
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                }
                Text {
                    text: "Terminal"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: Theme.accentGreen
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                }
            }
        }

        // Search Icon (Standard Mode)
        Text {
            visible: !root.isCommandMode
            anchors.verticalCenter: parent.verticalCenter
            text: "󰍉"
            font.family: Theme.iconFontFamily
            font.pixelSize: 15
            color: input.text.length > 0 ? Theme.accentBlue : Qt.rgba(255, 255, 255, 0.40)
            renderType: Text.NativeRendering
        }

        // Search Input
        Item {
            width: parent.width - (badge.visible ? badge.width + parent.spacing : 22) - (clearBtn.visible ? 24 : 0)
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            TextInput {
                id: input
                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                color: "#ffffff"
                font.family: Theme.fontFamily
                font.pixelSize: 13
                focus: true
                selectByMouse: true
                clip: true
                renderType: Text.NativeRendering

                Keys.onUpPressed: (event) => { root.navigateUp(); event.accepted = true; }
                Keys.onDownPressed: (event) => { root.navigateDown(); event.accepted = true; }
                Keys.onReturnPressed: (event) => { root.activate(); event.accepted = true; }
                Keys.onEnterPressed: (event) => { root.activate(); event.accepted = true; }
                Keys.onEscapePressed: (event) => { root.dismiss(); event.accepted = true; }
                onTextEdited: {
                    root.text = input.text;
                    root.queryChanged(input.text);
                }
                onTextChanged: {
                    root.text = input.text;
                }
            }

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: input.text.length === 0 && !input.inputMethodComposing
                text: "Search applications or type > for commands..."
                color: Qt.rgba(255, 255, 255, 0.35)
                font.family: Theme.fontFamily
                font.pixelSize: 13
                renderType: Text.NativeRendering
            }
        }

        // Clear Button (✕)
        Rectangle {
            id: clearBtn
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            radius: 9
            antialiasing: true
            visible: input.text.length > 0
            color: clearMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.25) : Qt.rgba(255, 255, 255, 0.12)

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: "#ffffff"
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.weight: Font.Bold
            }

            MouseArea {
                id: clearMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.clear();
                    root.queryChanged("");
                    input.forceActiveFocus();
                }
            }
        }
    }

    function clear() {
        input.text = "";
        root.text = "";
    }

    function setText(val) {
        input.text = val;
        root.text = val;
    }

    function forceFocus() {
        input.forceActiveFocus();
    }
}
