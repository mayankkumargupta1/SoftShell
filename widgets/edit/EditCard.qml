import QtQuick 2.15
import "../../theme"
import "../../services"
import "../../services/popover"

// EditCard — SoftShell Edit Dropdown Card
// Layout: Clipboard History -> Wallpaper -> Appearance
Rectangle {
    id: root

    property ClipboardHistoryService clipboardService: null

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
        spacing: 6

        // -------------------------------------------------------------------
        // 1. CLIPBOARD HISTORY
        // -------------------------------------------------------------------
        Item {
            width: parent.width
            height: 20

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "Clipboard"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.appleHeaderMuted
                renderType: Text.NativeRendering
            }
        }

        ClipboardHistorySection {
            width: parent.width
            service: root.clipboardService
            onRequestClose: PopoverManager.close("edit")
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.popoverSeparator
            antialiasing: true
        }

        // -------------------------------------------------------------------
        // 2. WALLPAPER
        // -------------------------------------------------------------------
        Item {
            width: parent.width
            height: 20

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "Wallpaper"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.appleHeaderMuted
                renderType: Text.NativeRendering
            }
        }

        WallpaperSection {
            width: parent.width
            onRequestClose: PopoverManager.close("edit")
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.popoverSeparator
            antialiasing: true
        }

        // -------------------------------------------------------------------
        // 3. APPEARANCE
        // -------------------------------------------------------------------
        Item {
            width: parent.width
            height: 20

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "Appearance"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.appleHeaderMuted
                renderType: Text.NativeRendering
            }
        }

        AppearanceSection {
            width: parent.width
            onRequestClose: PopoverManager.close("edit")
        }
    }
}
