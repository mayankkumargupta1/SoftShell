import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // Public interface
    property bool hasActiveCopy: false
    property string copiedPreview: ""
    property bool isImage: false
    property int triggerCount: 0

    signal copyDetected(string preview, bool isImage)

    // Grace period on startup: ignore the initial wl-paste read
    property bool _ready: false

    Timer {
        id: initTimer
        interval: 1000
        running: true
        repeat: false
        onTriggered: {
            root._ready = true;
        }
    }

    // Auto-dismiss timer: displays for 2200ms before returning to normal
    Timer {
        id: dismissTimer
        interval: 2200
        running: false
        repeat: false
        onTriggered: {
            root.hasActiveCopy = false;
        }
    }

    // Non-blocking Wayland clipboard watcher
    Process {
        id: clipProc
        running: true
        command: [
            "wl-paste", "--watch", "sh", "-c",
            "if wl-paste -l 2>/dev/null | grep -q 'image/'; then echo 'CLIP_IMAGE:'; else TXT=$(wl-paste -n 2>/dev/null | head -c 80 | tr '\\r\\n\\t' ' '); echo \"CLIP_TEXT:$TXT\"; fi"
        ]
        stdout: SplitParser {
            onRead: data => {
                if (!root._ready) return;

                let line = data.trim();
                if (line.startsWith("CLIP_IMAGE:")) {
                    root.isImage = true;
                    root.copiedPreview = "Image copied";
                    root.hasActiveCopy = true;
                    root.triggerCount++;
                    dismissTimer.restart();
                    root.copyDetected(root.copiedPreview, true);
                } else if (line.startsWith("CLIP_TEXT:")) {
                    let text = line.substring(10).trim();
                    if (text.length > 0) {
                        root.isImage = false;
                        root.copiedPreview = text;
                        root.hasActiveCopy = true;
                        root.triggerCount++;
                        dismissTimer.restart();
                        root.copyDetected(text, false);
                    }
                }
            }
        }
    }
}
