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
        return (count * (Theme.launcherItemHeight + 3)) + Theme.launcherInputHeight + 36;
    }

    // Inverted Dynamic Island Background with concave ear fillets (AMOLED Black)
    BottomIslandShape {
        id: islandShape
        anchors.fill: parent
        fillColor: Theme.islandBg
        radius: Theme.launcherRadius
        fillet: Theme.launcherFillet
    }

    // Top subtle specular highlight edge (bounded strictly inside body)
    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - (Theme.launcherFillet * 2) - 24
        height: 1
        color: Qt.rgba(255, 255, 255, 0.12)
        z: 3
    }

    // Content container strictly centered and bounded inside the AMOLED body
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - (Theme.launcherFillet * 2) - 16
        anchors.top: parent.top
        anchors.topMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        spacing: 6
        z: 4

        // 1. Applications & Commands List View
        Item {
            width: parent.width
            height: root.implicitHeight - Theme.launcherInputHeight - 34
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
                    spacing: 4
                    Text {
                        text: "󰍉"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 20
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
