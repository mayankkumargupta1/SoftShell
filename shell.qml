import QtQuick 2.15
import Quickshell
import Quickshell.Io
import "windows"
import "services/popover"

Scope {
    BarWindow {}
    NotchWindow {}
    LauncherWindow {}
    BatteryWindow {}
    NetworkWindow {}
    OsdWindow {}

    // Global IPC target: "quickshell ipc call popover toggle <name>"
    IpcHandler {
        target: "popover"
        function toggle(name: string): void { PopoverManager.toggle(name); }
        function open(name: string): void { PopoverManager.open(name); }
        function close(name: string): void { PopoverManager.close(name); }
        function closeAll(): void { PopoverManager.closeAll(); }
    }
}