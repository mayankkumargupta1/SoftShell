import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../services"
import "../services/popover"
import "../widgets/file"
import "../theme"

// FileWindow — Overlay PanelWindow displaying the SoftShell File Menu Popover
PanelWindow {
    id: root

    property bool isOpen: PopoverManager.activePopover === "file"

    onIsOpenChanged: {
        if (isOpen) {
            fileService.refresh();
        }
    }

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:file"

    visible: isOpen || popAnim.running

    FileService {
        id: fileService
    }

    function open() {
        PopoverManager.open("file");
    }

    function close() {
        PopoverManager.close("file");
    }

    function toggle() {
        PopoverManager.toggle("file");
    }

    // IPC handler allowing "quickshell ipc call file toggle"
    IpcHandler {
        target: "file"
        function toggle(): void { PopoverManager.toggle("file"); }
        function open(): void { PopoverManager.open("file"); }
        function close(): void { PopoverManager.close("file"); }
    }

    // Semi-transparent click-outside dismiss area
    MouseArea {
        anchors.fill: parent
        hoverEnabled: false
        onClicked: PopoverManager.closeAll()
    }

    // File Popover Card anchored neatly below the "File" menu item
    FileCard {
        id: card
        fileService: fileService
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.left: parent.left
        anchors.leftMargin: 122

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
