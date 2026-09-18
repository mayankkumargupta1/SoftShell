import QtQuick 2.15
import "../../theme"
import "../../services"

// EnergyModeSection — Section 2: Energy Mode card with dual profile selectors
Rectangle {
    id: root

    property PowerService powerService: null

    implicitWidth: parent ? parent.width : 380
    implicitHeight: contentCol.implicitHeight + 20
    radius: 8
    color: "#161618"
    border.color: Theme.popoverBorder
    border.width: 1

    Column {
        id: contentCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 12

        // Header: Title & Description
        Column {
            width: parent.width
            spacing: 4

            Text {
                text: "Energy Mode"
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: "#ffffff"
                renderType: Text.NativeRendering
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "Your Mac can optimise either its battery usage with Low Power Mode or its performance in resource-intensive tasks with High Power Mode."
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.textSecondary
                lineHeight: 1.15
                renderType: Text.NativeRendering
            }
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.popoverSeparator
        }

        // Row 1: On battery
        ProfileSelectorRow {
            id: batteryRow
            width: parent.width
            title: "On battery"
            z: isMenuOpen ? 20 : 1
            currentProfile: root.powerService ? root.powerService.onBatteryProfile : "balanced"
            onMenuToggled: {
                if (isMenuOpen) adapterRow.closeMenu();
            }
            onProfileSelected: prof => {
                if (root.powerService) root.powerService.setProfileMode("battery", prof);
            }
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.popoverSeparator
        }

        // Row 2: On power adapter
        ProfileSelectorRow {
            id: adapterRow
            width: parent.width
            title: "On power adapter"
            openUpwards: true
            z: isMenuOpen ? 20 : 1
            currentProfile: root.powerService ? root.powerService.onAcProfile : "performance"
            onMenuToggled: {
                if (isMenuOpen) batteryRow.closeMenu();
            }
            onProfileSelected: prof => {
                if (root.powerService) root.powerService.setProfileMode("ac", prof);
            }
        }
    }

    // Dismiss open menus when tapping anywhere else in the section
    MouseArea {
        anchors.fill: parent
        z: 10
        visible: batteryRow.isMenuOpen || adapterRow.isMenuOpen
        onClicked: {
            batteryRow.closeMenu();
            adapterRow.closeMenu();
        }
    }
}
