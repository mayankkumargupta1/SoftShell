import QtQuick 2.15
import Quickshell
import Quickshell.Io

// WallpaperService — Discovers and manages desktop wallpapers via mpvpaper.
// Backed by scripts/wallpaper.sh, supports images (.jpg/.png/.webp) and videos (.mp4).
Item {
    id: root

    property string currentWallpaper: ""
    property var wallpapers: []
    property bool isInitialized: false

    // When false the service never re-applies the wallpaper on construction, so
    // secondary consumers (e.g. the Edit popover picker) can read state without
    // killing and respawning the mpvpaper daemon owned by the primary instance.
    property bool autoInit: true

    signal wallpaperChanged(string path)

    readonly property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/scripts/wallpaper.sh"

    Component.onCompleted: {
        refreshList();
        if (root.autoInit) {
            initWallpaper();
        } else {
            refreshCurrent();
        }
    }

    function initWallpaper() {
        initProc.running = true;
    }

    // Reads the active wallpaper path without applying anything
    function refreshCurrent() {
        currentProc.running = true;
    }

    function nextWallpaper() {
        nextProc.running = true;
    }

    function prevWallpaper() {
        prevProc.running = true;
    }

    function setWallpaper(path) {
        setProc.command = [root.scriptPath, "set", path];
        setProc.running = true;
    }

    function refreshList() {
        listProc.running = true;
    }

    // Process to list wallpapers
    Process {
        id: listProc
        command: [root.scriptPath, "list"]
        // Collected as a whole stream: a SplitParser fires once per line, so each
        // callback overwrote the list and left only the final entry behind.
        stdout: StdioCollector {
            onStreamFinished: {
                root.wallpapers = text.trim().split("\n").filter(l => l.length > 0);
            }
        }
    }

    // Read-only probe of the active wallpaper (never applies it)
    Process {
        id: currentProc
        command: [root.scriptPath, "current"]
        stdout: StdioCollector {
            onStreamFinished: {
                let line = text.trim();
                if (line.length > 0) {
                    root.currentWallpaper = line;
                }
            }
        }
    }

    // Process to initialize wallpaper on shell start
    Process {
        id: initProc
        command: [root.scriptPath, "init"]
        stdout: SplitParser {
            onRead: data => {
                let line = data.trim();
                if (line.startsWith("Wallpaper set: ")) {
                    root.currentWallpaper = line.replace("Wallpaper set: ", "");
                    root.isInitialized = true;
                    root.wallpaperChanged(root.currentWallpaper);
                }
            }
        }
    }

    // Next wallpaper process
    Process {
        id: nextProc
        command: [root.scriptPath, "next"]
        stdout: SplitParser {
            onRead: data => {
                let line = data.trim();
                if (line.startsWith("Wallpaper set: ")) {
                    root.currentWallpaper = line.replace("Wallpaper set: ", "");
                    root.wallpaperChanged(root.currentWallpaper);
                }
            }
        }
    }

    // Prev wallpaper process
    Process {
        id: prevProc
        command: [root.scriptPath, "prev"]
        stdout: SplitParser {
            onRead: data => {
                let line = data.trim();
                if (line.startsWith("Wallpaper set: ")) {
                    root.currentWallpaper = line.replace("Wallpaper set: ", "");
                    root.wallpaperChanged(root.currentWallpaper);
                }
            }
        }
    }

    // Explicit set process
    Process {
        id: setProc
        stdout: SplitParser {
            onRead: data => {
                let line = data.trim();
                if (line.startsWith("Wallpaper set: ")) {
                    root.currentWallpaper = line.replace("Wallpaper set: ", "");
                    root.wallpaperChanged(root.currentWallpaper);
                }
            }
        }
    }
}
