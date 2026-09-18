import QtQuick 2.15
import Quickshell
import "../../theme"
import "../../services"

// BatteryCard — Main container coordinating compact dropdown and expanded Settings view
Rectangle {
    id: root

    property PowerService powerService: null
    property bool expanded: false

    implicitWidth: expanded ? 410 : 260
    implicitHeight: (expanded ? expandedView.implicitHeight : compactView.implicitHeight) + 20
    radius: 10
    color: "#000000" // Pure 100% AMOLED Black
    border.color: Theme.popoverBorder
    border.width: 1
    clip: false

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 10

        // Compact Dropdown View
        BatteryCompactView {
            id: compactView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            powerService: root.powerService
            visible: opacity > 0
            opacity: root.expanded ? 0 : 1
            scale: root.expanded ? 0.95 : 1.0

            Behavior on opacity { NumberAnimation { duration: 160 } }
            Behavior on scale { NumberAnimation { duration: 160 } }

            onExpandRequested: {
                root.expanded = true;
                if (root.powerService) {
                    root.powerService.fetchHistory();
                    root.powerService.fetchProfileModes();
                }
            }
        }

        // Expanded Settings View
        BatteryExpandedView {
            id: expandedView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            powerService: root.powerService
            visible: opacity > 0
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1.0 : 0.96

            Behavior on opacity { NumberAnimation { duration: 180 } }
            Behavior on scale { NumberAnimation { duration: 180 } }

            onCollapseRequested: {
                root.expanded = false;
            }
        }
    }
}
