import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../services"
import "../services/popover"
import "../widgets/go"
import "../theme"

// GoWindow — Overlay PanelWindow displaying the SoftShell Go Carousel Popover
PanelWindow {
    id: root

    property bool isOpen: PopoverManager.activePopover === "go"

    onIsOpenChanged: {
        if (isOpen) {
            navService.refresh();
        }
    }

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:go"

    visible: isOpen || popAnim.running

    WorkspaceNavService {
        id: navService
    }

    function open() {
        PopoverManager.open("go");
    }

    function close() {
        PopoverManager.close("go");
    }

    function toggle() {
        PopoverManager.toggle("go");
    }

    // IPC handler allowing "quickshell ipc call go toggle"
    IpcHandler {
        target: "go"
        function toggle(): void { PopoverManager.toggle("go"); }
        function open(): void { PopoverManager.open("go"); }
        function close(): void { PopoverManager.close("go"); }
    }

    // Semi-transparent click-outside dismiss area
    MouseArea {
        anchors.fill: parent
        hoverEnabled: false
        onClicked: PopoverManager.closeAll()
    }

    // Go Carousel Popover Card anchored neatly below the "Go" menu item
    GoCard {
        id: card
        service: navService
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.left: parent.left
        anchors.leftMargin: Math.max(16, Math.min(parent.width - card.width - 16, PopoverManager.goMenuX - 20))

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
