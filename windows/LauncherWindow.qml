import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../services"
import "../widgets/launcher"
import "../theme"

PanelWindow {
    id: root

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusiveZone: 0
    color: "transparent"

    focusable: launcherService.isOpen
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:launcher"
    WlrLayershell.keyboardFocus: launcherService.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: launcherService.isOpen || slideAnim.running

    LauncherService {
        id: launcherService

        onOpened: {
            launcherWidget.clearInput();
            focusTimer.restart();
        }

        onClosed: {
            launcherWidget.clearInput();
        }
    }

    Timer {
        id: focusTimer
        interval: 35
        repeat: false
        onTriggered: {
            launcherWidget.focusInput();
        }
    }

    // Global Shortcut & IPC Handler for Super + A integration
    GlobalShortcut {
        name: "toggleLauncher"
        onPressed: launcherService.toggle()
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { launcherService.toggle(); }
        function open(): void { launcherService.open(); }
        function close(): void { launcherService.close(); }
        function setQuery(text: string): void {
            if (!launcherService.isOpen) launcherService.open();
            launcherService.searchQuery = text;
        }
        function activate(): void {
            launcherService.activateSelected();
        }
    }

    // Semi-transparent backdrop scrim (clicking dismisses launcher)
    Rectangle {
        id: scrim
        anchors.fill: parent
        color: Theme.launcherScrimBg
        opacity: launcherService.isOpen ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: launcherService.close()
        }
    }

    // Bottom Inverted Dynamic Island Launcher
    LauncherWidget {
        id: launcherWidget
        launcherService: launcherService
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: launcherService.isOpen ? 0 : -implicitHeight - 40

        Behavior on anchors.bottomMargin {
            NumberAnimation {
                id: slideAnim
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }
}
