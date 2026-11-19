import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../services"
import "../services/popover"
import "../widgets/view"
import "../theme"

// ViewWindow — Overlay PanelWindow displaying the SoftShell View Menu Popover
PanelWindow {
    id: root

    property bool isOpen: PopoverManager.activePopover === "view"

    onIsOpenChanged: {
        if (isOpen) {
            viewService.refresh();
        }
    }

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:view"

    visible: isOpen || popAnim.running

    ViewService {
        id: viewService
    }

    function open() {
        PopoverManager.open("view");
    }

    function close() {
        PopoverManager.close("view");
    }

    function toggle() {
        PopoverManager.toggle("view");
    }

    // IPC handler allowing "quickshell ipc call view toggle"
    IpcHandler {
        target: "view"
        function toggle(): void { PopoverManager.toggle("view"); }
        function open(): void { PopoverManager.open("view"); }
        function close(): void { PopoverManager.close("view"); }
    }

    // Semi-transparent click-outside dismiss area
    MouseArea {
        anchors.fill: parent
        hoverEnabled: false
        onClicked: PopoverManager.closeAll()
    }

    // View Popover Card anchored neatly below the "View" menu item
    ViewCard {
        id: card
        viewService: viewService
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.left: parent.left
        anchors.leftMargin: PopoverManager.viewMenuX

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
