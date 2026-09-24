import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../services"
import "../services/popover"
import "../widgets/edit"
import "../theme"

// EditWindow — Overlay PanelWindow displaying the SoftShell Edit Menu Popover
PanelWindow {
    id: root

    property bool isOpen: PopoverManager.activePopover === "edit"

    // Pull a fresh clipboard history every time the popover opens instead of
    // polling cliphist in the background
    onIsOpenChanged: {
        if (isOpen) {
            clipboardHistoryService.refresh();
        }
    }

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:edit"

    visible: isOpen || popAnim.running

    ClipboardHistoryService {
        id: clipboardHistoryService
    }

    function open() {
        PopoverManager.open("edit");
    }

    function close() {
        PopoverManager.close("edit");
    }

    function toggle() {
        PopoverManager.toggle("edit");
    }

    // IPC handler allowing "quickshell ipc call edit toggle"
    IpcHandler {
        target: "edit"
        function toggle(): void { PopoverManager.toggle("edit"); }
        function open(): void { PopoverManager.open("edit"); }
        function close(): void { PopoverManager.close("edit"); }
    }

    // Click-outside dismiss area
    MouseArea {
        anchors.fill: parent
        hoverEnabled: false
        onClicked: PopoverManager.closeAll()
    }

    // Edit Popover Card anchored neatly below the "Edit" menu item
    EditCard {
        id: card
        clipboardService: clipboardHistoryService
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.left: parent.left
        anchors.leftMargin: PopoverManager.editMenuX

        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1.0 : 0.94
        transformOrigin: Item.TopLeft

        Behavior on opacity {
            NumberAnimation {
                id: popAnim
                duration: 160
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            SpringAnimation {
                spring: 4.0
                damping: 0.35
                mass: 0.8
            }
        }

        // Prevent clicks inside the card from dismissing it
        MouseArea {
            anchors.fill: parent
            z: -1
        }
    }
}
