import QtQuick 2.15
import Quickshell
import Quickshell.Io

// ViewService — Non-blocking backend service for window presentation
// and display controls on Hyprland 0.57.0+.
Item {
    id: root

    // --- Active Window State ---
    property bool isFullscreen: false
    property bool isFloating: false
    property string activeTitle: ""
    property string activeClass: ""

    // --- Monitor & Refresh Rate State ---
    property string monitorName: "eDP-1"
    property string monitorDesc: "Primary Display"
    property int monitorWidth: 2880
    property int monitorHeight: 1800
    property int refreshRate: 60

    signal stateUpdated()

    // Query active window status asynchronously
    Process {
        id: winProc
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                let txt = this.text.trim();
                if (!txt || txt === "") return;
                try {
                    let data = JSON.parse(txt);
                    root.isFullscreen = (data.fullscreen !== 0 && data.fullscreen !== false);
                    root.isFloating = !!data.floating;
                    root.isPinned = !!data.pinned;
                    root.activeTitle = data.title || "";
                    root.activeClass = data.class || "";
                    root.stateUpdated();
                } catch (e) {
                    // Ignore transient parsing errors during window close/switch
                }
            }
        }
    }

    // Query active monitor & refresh rate status asynchronously
    Process {
        id: monProc
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                let txt = this.text.trim();
                if (!txt || txt === "") return;
                try {
                    let monitors = JSON.parse(txt);
                    if (Array.isArray(monitors) && monitors.length > 0) {
                        // Use focused monitor or fallback to first
                        let m = monitors.find(x => x.focused) || monitors[0];
                        root.monitorName = m.name || "eDP-1";
                        root.monitorDesc = (m.description || m.model || "Display").split("·")[0].trim();
                        root.monitorWidth = m.width || 2880;
                        root.monitorHeight = m.height || 1800;
                        root.refreshRate = Math.round(m.refreshRate || 60);
                        root.stateUpdated();
                    }
                } catch (e) {
                    // Ignore parsing errors
                }
            }
        }
    }

    // Refresh all states (invoked when View popover opens)
    function refresh(): void {
        winProc.running = false;
        winProc.running = true;
        monProc.running = false;
        monProc.running = true;
    }

    // --- Window Actions (Hyprland 0.57.0 Lua Dispatchers) ---

    function toggleFullscreen(): void {
        Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.window.fullscreen()"]);
        root.isFullscreen = !root.isFullscreen;
    }

    function toggleFloating(): void {
        Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.window.float({ action = 'toggle' })"]);
        root.isFloating = !root.isFloating;
    }

    // --- Monitor Refresh Rate Switcher ---

    function setRefreshRate(rate: int): void {
        root.refreshRate = rate;
        let modeStr = root.monitorWidth + "x" + root.monitorHeight + "@" + rate;
        let luaCmd = "hl.monitor({ output = '" + root.monitorName + "', mode = '" + modeStr + "', position = 'auto', scale = 2 })";
        Quickshell.execDetached(["hyprctl", "repl", luaCmd]);
    }
}
