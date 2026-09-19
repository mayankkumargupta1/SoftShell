pragma Singleton
import QtQuick 2.15

// PopoverManager — Centralized singleton service to manage SoftShell menu bar popovers.
// Ensures strict mutual exclusivity: opening any popover automatically closes any other.
QtObject {
    id: root

    // Name of currently active popover ("" when no popover is open)
    property string activePopover: ""

    // Read-only convenience property
    readonly property bool hasActivePopover: activePopover !== ""

    // Signals for fine-grained observation
    signal popoverOpened(string name)
    signal popoverClosed(string name)

    function isOpen(name) {
        return root.activePopover === name;
    }

    function open(name) {
        if (!name || name === "") return;
        if (root.activePopover === name) return;

        var prev = root.activePopover;
        root.activePopover = name;

        if (prev !== "") {
            root.popoverClosed(prev);
        }
        root.popoverOpened(name);
    }

    function close(name) {
        if (!name || name === "" || root.activePopover === name) {
            var prev = root.activePopover;
            root.activePopover = "";
            if (prev !== "") {
                root.popoverClosed(prev);
            }
        }
    }

    function closeAll() {
        root.close("");
    }

    function toggle(name) {
        if (root.activePopover === name) {
            root.close(name);
        } else {
            root.open(name);
        }
    }
}
