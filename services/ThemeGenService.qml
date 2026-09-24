import QtQuick 2.15
import Quickshell
import Quickshell.Io
import "../theme"

// ThemeGenService — Derives an accent palette from the current wallpaper via
// scripts/theme_from_wallpaper.sh and publishes it into Theme's generated tokens.
Item {
    id: root

    // 1. Public interface
    property bool available: false
    property bool generating: false
    property bool failed: false
    property color accent: Theme.accentBlue
    property color accentAlt: Theme.accentGreen
    property color surface: Theme.popoverCardBg
    property string sourceColor: ""

    signal generated()

    // 3. Internal state
    readonly property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/scripts/theme_from_wallpaper.sh"
    readonly property string colorsPath: Quickshell.env("HOME") + "/.config/softshell/colors.json"

    function regenerate() {
        if (root.generating)
            return;
        root.failed = false;
        root.generating = true;
        genProc.running = true;
    }

    function reload() {
        colorsFile.reload();
    }

    function _apply(json) {
        if (!json || !json.accent) {
            root.available = false;
            root._publish();
            return;
        }
        root.accent = json.accent;
        root.accentAlt = json.accentAlt ? json.accentAlt : json.accent;
        root.surface = json.surface ? json.surface : Theme.popoverCardBg;
        root.sourceColor = json.source ? json.source : "";
        root.available = true;
        root._publish();
        root.generated();
    }

    function _publish() {
        Theme.genAvailable = root.available;
        Theme.genAccent = root.accent;
        Theme.genAccentAlt = root.accentAlt;
        Theme.genSurface = root.surface;
    }

    // 6. Child Elements (non-visual)
    FileView {
        id: colorsFile
        path: root.colorsPath

        onLoaded: {
            try {
                root._apply(JSON.parse(colorsFile.text()));
            } catch (e) {
                root.available = false;
                root._publish();
            }
        }

        onLoadFailed: {
            root.available = false;
            root._publish();
        }
    }

    Process {
        id: genProc
        command: [root.scriptPath]

        onExited: (exitCode, exitStatus) => {
            root.generating = false;
            if (exitCode === 0) {
                colorsFile.reload();
            } else {
                root.failed = true;
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0)
                    console.warn("ThemeGenService:", text.trim());
            }
        }
    }

    Component.onCompleted: colorsFile.reload()
}
