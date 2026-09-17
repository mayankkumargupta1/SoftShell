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

    signal wallpaperChanged(string path)

    readonly property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/scripts/wallpaper.sh"

    Component.onCompleted: {
        refreshList();
        initWallpaper();
    }

    function initWallpaper() {
        initProc.running = true;
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
        stdout: SplitParser {
            onRead: data => {
                let lines = data.trim().split("\n").filter(l => l.length > 0);
                root.wallpapers = lines;
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
