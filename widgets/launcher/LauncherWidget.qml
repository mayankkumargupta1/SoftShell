import QtQuick 2.15
import "../../components"
import "../../services"
import "../../theme"

Item {
    id: root

    property LauncherService launcherService

    implicitWidth: Theme.launcherWidth
    implicitHeight: calculateHeight()

    Behavior on implicitHeight {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    function calculateHeight() {
        if (!launcherService) return 180;
        var count = Math.min(5, Math.max(1, launcherService.filteredApps.length));
        return (count * (Theme.launcherItemHeight + 4)) + Theme.launcherInputHeight + 40;
    }

    // Inverted Dynamic Island Background with concave ear fillets (AMOLED Black)
    BottomIslandShape {
        id: islandShape
        anchors.fill: parent
        fillColor: Theme.islandBg
        radius: Theme.launcherRadius
        fillet: Theme.launcherFillet
    }


    // Content container strictly centered and bounded inside the AMOLED body
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - (Theme.launcherFillet * 2) - 12
        anchors.top: parent.top
        anchors.topMargin: 14
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        spacing: 6
        z: 4

        // 1. Applications & Commands List View
        Item {
            width: parent.width
            height: root.implicitHeight - Theme.launcherInputHeight - 40
            clip: true

            ListView {
                id: appList
                anchors.fill: parent
                visible: launcherService && launcherService.filteredApps.length > 0
                model: launcherService ? launcherService.filteredApps : []
                spacing: 3
                currentIndex: launcherService ? launcherService.selectedIndex : 0
                highlightFollowsCurrentItem: true
                boundsBehavior: Flickable.StopAtBounds

                delegate: LauncherAppItem {
                    width: appList.width
                    app: modelData
                    isSelected: launcherService ? index === launcherService.selectedIndex : false
                    onClicked: {
                        if (launcherService) launcherService.activateItem(modelData);
                    }
                    onHovered: {
                        if (launcherService) launcherService.selectedIndex = index;
                    }
                }
            }

            // Empty State
            Item {
                anchors.fill: parent
                visible: !launcherService || launcherService.filteredApps.length === 0
                Column {
                    anchors.centerIn: parent
                    spacing: 6
                    Text {
                        text: "󰍉"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 22
                        color: Theme.textTertiary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "No applications or commands found"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.textSecondary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // Subtle Apple Frosted Hairline Divider
        Rectangle {
            width: parent.width - 12
            anchors.horizontalCenter: parent.horizontalCenter
            height: 1
            color: Qt.rgba(255, 255, 255, 0.08)
        }

        // 2. Bottom Search Bar Capsule
        LauncherSearchBar {
            id: searchBar
            width: parent.width
            text: launcherService ? launcherService.searchQuery : ""
            onQueryChanged: (q) => {
                if (launcherService && launcherService.searchQuery !== q) {
                    launcherService.searchQuery = q;
                }
            }
            onNavigateUp: launcherService.navigateUp()
            onNavigateDown: launcherService.navigateDown()
            onActivate: launcherService.activateSelected()
            onDismiss: launcherService.close()
        }
    }

    function focusInput() {
        searchBar.forceFocus();
    }

    function clearInput() {
        searchBar.clear();
    }
}
