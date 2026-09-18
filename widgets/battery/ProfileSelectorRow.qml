import QtQuick 2.15
import "../../theme"

// ProfileSelectorRow — Reusable row for setting power profile with dropdown
Item {
    id: root

    property string title: ""
    property string description: "SoftShell will automatically choose the best level of performance and energy usage."
    property string currentProfile: "balanced"
    property bool openUpwards: false
    property bool isMenuOpen: false
    signal profileSelected(string profile)
    signal menuToggled()

    function closeMenu() {
        isMenuOpen = false;
    }

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
        color: btnHover.hovered ? "#323236" : "#242428"
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

        HoverHandler {
            id: btnHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: {
                root.isMenuOpen = !root.isMenuOpen;
                root.menuToggled();
            }
        }
    }

    ProfileDropdownMenu {
        id: menu
        visible: root.isMenuOpen
        z: 100
        anchors.top: root.openUpwards ? undefined : btn.bottom
        anchors.topMargin: root.openUpwards ? 0 : 4
        anchors.bottom: root.openUpwards ? btn.top : undefined
        anchors.bottomMargin: root.openUpwards ? 4 : 0
        anchors.right: btn.right
        currentProfile: root.currentProfile
        onProfileSelected: prof => {
            root.profileSelected(prof);
            root.isMenuOpen = false;
        }
    }
}
