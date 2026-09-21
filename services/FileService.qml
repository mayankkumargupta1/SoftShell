import QtQuick 2.15
import Quickshell
import Quickshell.Io

// FileService — Asynchronous backend for SoftShell File menu
// Non-blocking execution of scripts/file_menu.py via Quickshell Process.
Item {
    id: root

    property var downloads: []
    property var bookmarks: []
    property int trashCount: 0
    property string trashText: "Empty"
    property string trashGlyph: "󰩺"
    property string storageUsed: ""
    property string storageAvailable: ""
    property bool isLoading: false

    readonly property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/scripts/file_menu.py"

    Component.onCompleted: {
        refresh();
    }

    function refresh() {
        if (statusProc.running) return;
        root.isLoading = true;
        statusProc.command = ["python3", root.scriptPath, "status"];
        statusProc.running = true;
    }

    function openFile(path) {
        if (!path || path === "") return;
        Quickshell.execDetached(["python3", root.scriptPath, "open", path]);
    }

    function revealFile(path) {
        if (!path || path === "") return;
        Quickshell.execDetached(["python3", root.scriptPath, "reveal", path]);
    }

    function openFolder(path) {
        if (!path || path === "") return;
        Quickshell.execDetached(["python3", root.scriptPath, "open-folder", path]);
    }

    function emptyTrash() {
        Quickshell.execDetached(["python3", root.scriptPath, "empty-trash"]);
        // Trigger quick refresh after short delay
        refreshTimer.restart();
    }

    Timer {
        id: refreshTimer
        interval: 600
        repeat: false
        onTriggered: root.refresh()
    }

    Process {
        id: statusProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.isLoading = false;
                try {
                    let data = JSON.parse(this.text.trim());
                    if (data.downloads && Array.isArray(data.downloads)) {
                        root.downloads = data.downloads;
                    }
                    if (data.bookmarks && Array.isArray(data.bookmarks)) {
                        root.bookmarks = data.bookmarks;
                    }
                    if (data.trash) {
                        root.trashCount = data.trash.count || 0;
                        root.trashText = data.trash.text || "Empty";
                        root.trashGlyph = data.trash.glyph || "󰩺";
                    }
                    if (data.storage) {
                        root.storageUsed = data.storage.used || "";
                        root.storageAvailable = data.storage.available || "";
                    }
                } catch(e) {
                    console.warn("FileService parse error:", e);
                }
            }
        }
    }
}
