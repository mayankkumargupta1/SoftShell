import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../services"
import "../widgets/battery"
import "../theme"

// BatteryWindow — Overlay PanelWindow displaying the SoftShell Battery Dropdown Popover
PanelWindow {
    id: root

    property bool isOpen: false

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:battery"

    visible: isOpen || popAnim.running

    PowerService {
        id: powerService
    }

    function open() {
        isOpen = true;
        powerService.refreshStats();
    }

    function close() {
        isOpen = false;
        card.expanded = false;
    }

    function toggle() {
        if (isOpen) close();
        else open();
    }

    // IPC handler allowing "quickshell ipc call battery toggle"
    IpcHandler {
        target: "battery"
        function toggle(): void { root.toggle(); }
        function open(): void { root.open(); }
        function close(): void { root.close(); }
    }

    // Global Shortcut toggle
    GlobalShortcut {
        name: "toggleBattery"
        onPressed: root.toggle()
    }

    // Semi-transparent click-outside dismiss area
    MouseArea {
        anchors.fill: parent
        hoverEnabled: false
        onClicked: root.close()
    }

    // Battery Popover Card anchored neatly below the right-side status bar
    BatteryCard {
        id: card
        powerService: powerService
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.right: parent.right
        anchors.rightMargin: 84

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
