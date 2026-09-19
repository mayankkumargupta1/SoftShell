import QtQuick 2.15
import "../../theme"

// ProfileSelectorRow — Reusable row for setting power profile with dropdown
Item {
    id: root

    property string title: ""
    property string description: "SoftShell will automatically choose the best level of performance and energy usage."
    property string currentProfile: "balanced"
    signal buttonClicked()

    function profileLabel(prof) {
        if (prof === "power-saver") return "Low Power";
        if (prof === "performance") return "High Power";
        return "Automatic";
    }

    implicitWidth: parent ? parent.width : 380
    implicitHeight: Math.max(infoCol.implicitHeight, btn.height)

    Column {
        id: infoCol
        anchors.left: parent.left
        anchors.right: btn.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            text: root.title
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: "#ffffff"
            renderType: Text.NativeRendering
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: root.description
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: Theme.textSecondary
            renderType: Text.NativeRendering
        }
    }

    Rectangle {
        id: btn
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 104
        height: 24
        radius: 5
        color: btnArea.containsMouse ? "#323236" : "#242428"
        border.color: Theme.popoverBorder
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: root.profileLabel(root.currentProfile)
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: "#ffffff"
                renderType: Text.NativeRendering
            }

            Text {
                text: "↕"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.textSecondary
                renderType: Text.NativeRendering
            }
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.buttonClicked()
        }
    }
}
