import QtQuick 2.15
import Quickshell
import Quickshell.Io

// ClipboardHistoryService — Asynchronous cliphist backend for the Edit menu.
// Sole responsibility: read/restore/wipe the Wayland clipboard history.
// Never polls: the Edit popover calls refresh() when it opens.
Item {
    id: root

    // 1. Public interface
    // Each entry: { id: string, preview: string, isBinary: bool }
    property var entries: []
    property bool available: true
    property bool loaded: false

    readonly property int count: entries.length

    // 3. Internal state
    // Keep a little more than the UI shows so the list survives minor churn
    readonly property int _maxEntries: 20
    readonly property string _binaryMarker: "[[ binary data"
    readonly property string _shell: Quickshell.env("SHELL") || "/usr/bin/zsh"
    property bool _pending: false

    function refresh() {
        if (listProc.running) return;
        // Optimistic: onExited flips this back to false if cliphist failed
        root.available = true;
        root._pending = true;
        watchdog.restart();
        listProc.running = true;
    }

    // Restore an entry to the clipboard. Only numeric cliphist ids are ever
    // interpolated into the shell string, so a preview can't inject a command.
    function copyItem(id) {
        var safeId = String(id);
        if (!/^[0-9]+$/.test(safeId)) {
            console.warn("ClipboardHistoryService: refusing non-numeric id", safeId);
            return;
        }
        copyProc.command = [root._shell, "-c", "cliphist decode " + safeId + " | wl-copy"];
        copyProc.running = true;
    }

    function clearHistory() {
        if (wipeProc.running) return;
        wipeProc.running = true;
    }

    function _parseList(text) {
        var lines = text.split("\n");
        var out = [];
        for (var i = 0; i < lines.length && out.length < root._maxEntries; i++) {
            var line = lines[i];
            if (!line || line.trim() === "") continue;

            // Split on the FIRST tab only — previews may contain tabs
            var tab = line.indexOf("\t");
            if (tab <= 0) continue;

            var id = line.substring(0, tab).trim();
            var preview = line.substring(tab + 1).trim();
            if (id === "" || preview === "") continue;

            out.push({
                id: id,
                preview: preview,
                isBinary: preview.indexOf(root._binaryMarker) !== -1
            });
        }
        return out;
    }

    // 6. Child elements (processes only — a service has no visual tree)
    Process {
        id: listProc
        command: ["cliphist", "list"]

        stdout: StdioCollector {
            // exited may land before the stream drains, so never trust partial
            // output from a failed run
            onStreamFinished: root.entries = root.available ? root._parseList(this.text) : []
        }

        onExited: (exitCode, exitStatus) => {
            root._pending = false;
            watchdog.stop();
            root.available = exitCode === 0;
            if (exitCode !== 0) root.entries = [];
            root.loaded = true;
        }
    }

    Process {
        id: copyProc
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) console.warn("ClipboardHistoryService: decode failed", exitCode);
        }
    }

    Process {
        id: wipeProc
        command: ["cliphist", "wipe"]
        onExited: (exitCode, exitStatus) => {
            root.entries = [];
            root.refresh();
        }
    }

    // Fallback for a launch that never reaches exited (cliphist not installed):
    // degrade to the "unavailable" state instead of hanging on "not loaded"
    Timer {
        id: watchdog
        interval: 2000
        repeat: false
        onTriggered: {
            if (!root._pending) return;
            root._pending = false;
            root.available = false;
            root.entries = [];
            root.loaded = true;
        }
    }
}
