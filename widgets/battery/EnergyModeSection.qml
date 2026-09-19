import QtQuick 2.15
import "../../theme"
import "../../services"

// EnergyModeSection — Section 2: Energy Mode card with dual profile selectors
Rectangle {
    id: root

    property PowerService powerService: null

    z: (batteryMenu.visible || adapterMenu.visible) ? 100 : 1
    implicitWidth: parent ? parent.width : 380
    implicitHeight: Math.max(contentCol.implicitHeight + 24, 215)
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
                text: "SoftShell can optimise either its battery usage with Low Power Mode or its performance in resource-intensive tasks with High Power Mode."
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
            currentProfile: root.powerService ? root.powerService.onBatteryProfile : "balanced"
            onButtonClicked: {
                adapterMenu.visible = false;
                batteryMenu.visible = !batteryMenu.visible;
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
            currentProfile: root.powerService ? root.powerService.onAcProfile : "performance"
            onButtonClicked: {
                batteryMenu.visible = false;
                adapterMenu.visible = !adapterMenu.visible;
            }
        }
    }

    // Dismiss open menus when tapping anywhere else in the popover
    MouseArea {
        id: dismissArea
        anchors.fill: parent
        anchors.margins: -500
        z: 50
        visible: batteryMenu.visible || adapterMenu.visible
        onClicked: {
            batteryMenu.visible = false;
            adapterMenu.visible = false;
        }
    }

    // Dropdown for Row 1 (On battery) - opens downwards
    ProfileDropdownMenu {
        id: batteryMenu
        visible: false
        z: 100
        anchors.right: parent.right
        anchors.rightMargin: 12
        y: contentCol.y + batteryRow.y + batteryRow.height + 2
        currentProfile: root.powerService ? root.powerService.onBatteryProfile : "balanced"
        onProfileSelected: prof => {
            if (root.powerService) root.powerService.setProfileMode("battery", prof);
            batteryMenu.visible = false;
        }
    }

    // Dropdown for Row 2 (On power adapter) - opens upwards
    ProfileDropdownMenu {
        id: adapterMenu
        visible: false
        z: 100
        anchors.right: parent.right
        anchors.rightMargin: 12
        y: contentCol.y + adapterRow.y - implicitHeight - 2
        currentProfile: root.powerService ? root.powerService.onAcProfile : "performance"
        onProfileSelected: prof => {
            if (root.powerService) root.powerService.setProfileMode("ac", prof);
            adapterMenu.visible = false;
        }
    }
}
