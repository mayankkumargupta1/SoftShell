import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../services"
import "../services/popover"
import "../widgets/network"
import "../theme"

// NetworkWindow — Overlay PanelWindow displaying the SoftShell Network Settings Popover
PanelWindow {
    id: root

    property bool isOpen: PopoverManager.activePopover === "network"

    onIsOpenChanged: {
        if (isOpen) {
            networkService.refreshStatus();
            networkService.scanNetworks();
        } else {
            card.reset();
        }
    }

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:network"

    visible: isOpen || popAnim.running

    NetworkService {
        id: networkService
    }

    function open() {
        PopoverManager.open("network");
    }

    function close() {
        PopoverManager.close("network");
    }

    function toggle() {
        PopoverManager.toggle("network");
    }

    IpcHandler {
        target: "network"
        function toggle(): void { PopoverManager.toggle("network"); }
        function open(): void { PopoverManager.open("network"); }
        function close(): void { PopoverManager.close("network"); }
        function openPassword(ssid: string): void {
            PopoverManager.open("network");
            card.targetSsid = ssid;
            card.isPasswordView = true;
        }
    }

    // Global Shortcut toggle
    GlobalShortcut {
        name: "toggleNetwork"
        onPressed: PopoverManager.toggle("network")
    }

    // Semi-transparent click-outside dismiss area
    MouseArea {
        anchors.fill: parent
        hoverEnabled: false
        onClicked: PopoverManager.closeAll()
    }

    // Network Popover Card anchored neatly below the right-side status bar
    NetworkCard {
        id: card
        networkService: networkService
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.right: parent.right
        anchors.rightMargin: 46

        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1.0 : 0.94
        transformOrigin: Item.TopRight

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
