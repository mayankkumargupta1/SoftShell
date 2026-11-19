import QtQuick 2.15
import "../../theme"
import "../../services"
import "../../services/popover"

// ViewCard — SoftShell View Dropdown Card
// Layout: Window Presentation Actions -> Display & Refresh Rate
Rectangle {
    id: root

    property ViewService viewService: null

    implicitWidth: 320
    implicitHeight: mainCol.implicitHeight + 20

    radius: Theme.popoverRadius
    color: Theme.popoverBg
    border.color: Theme.popoverBorder
    border.width: 1
    antialiasing: true

    Column {
        id: mainCol
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        spacing: 10

        // 1. WINDOW ACTIONS (Fullscreen, Float, Pin, Scratchpad)
        WindowActionsSection {
            width: parent.width
            service: root.viewService
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.popoverSeparator
            antialiasing: true
        }

        // 2. DISPLAY & REFRESH RATE (60Hz / 120Hz Switcher)
        DisplaySection {
            width: parent.width
            service: root.viewService
        }
    }
}
