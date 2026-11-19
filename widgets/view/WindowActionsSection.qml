import QtQuick 2.15
import "../../theme"
import "../../services"
import "../../services/popover"

// WindowActionsSection — Window presentation controls (fullscreen, float, pin, scratchpad)
Item {
    id: root

    property ViewService service: null

    implicitWidth: parent ? parent.width : 304
    implicitHeight: col.implicitHeight

    Column {
        id: col
        width: parent.width
        spacing: 4

        // Section Header
        Item {
            width: parent.width
            height: 20

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "Window Presentation"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.appleHeaderMuted
                renderType: Text.NativeRendering
            }

            // Shows the active window title (shortened)
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                width: 140
                text: root.service ? root.service.activeClass : ""
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.weight: Font.Medium
                color: Theme.appleSubtext
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
                renderType: Text.NativeRendering
            }
        }

        // 1. Fullscreen Toggle
        ViewItemRow {
            glyph: root.service && root.service.isFullscreen ? "󰊓" : "󰊔"
            title: root.service && root.service.isFullscreen ? "Exit Fullscreen" : "Enter Fullscreen"
            shortcut: "Super + M"
            active: root.service ? root.service.isFullscreen : false
            activeColor: Theme.accentGreen
            onClicked: {
                if (root.service) root.service.toggleFullscreen();
                PopoverManager.close("view");
            }
        }

        // 2. Float / Tile Toggle
        ViewItemRow {
            glyph: root.service && root.service.isFloating ? "󰉈" : "󰙵"
            title: root.service && root.service.isFloating ? "Tile Window" : "Float Window"
            shortcut: "Super + Shift + F"
            active: root.service ? root.service.isFloating : false
            activeColor: Theme.accentBlue
            onClicked: {
                if (root.service) root.service.toggleFloating();
                PopoverManager.close("view");
            }
        }
    }
}
