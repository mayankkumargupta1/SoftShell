import QtQuick 2.15
import Quickshell
import Quickshell.Io

// BrightnessService — Monitors display backlight brightness using sysfs FileView
Item {
    id: root

    property string backlightName: "intel_backlight"
    readonly property string actualPath: "/sys/class/backlight/" + backlightName + "/actual_brightness"
    readonly property string maxPath: "/sys/class/backlight/" + backlightName + "/max_brightness"

    property real brightness: 0.15 // Normalized 0.0 to 1.0
    property int actualBrightness: 75
    property int maxBrightness: 496

    signal brightnessUpdated(real newBrightness)

    property bool _initialized: false

    FileView {
        id: maxFile
        path: root.maxPath
        onLoaded: root._updateMax()
    }

    FileView {
        id: actualFile
        path: root.actualPath
        onLoaded: root._updateActual()
    }

    function _updateMax(): void {
        let txt = maxFile.text().trim();
        let val = parseInt(txt);
        if (!isNaN(val) && val > 0) {
            root.maxBrightness = val;
        }
    }

    function _updateActual(): void {
        let txt = actualFile.text().trim();
        let val = parseInt(txt);
        if (!isNaN(val) && val >= 0) {
            let prevVal = root.actualBrightness;
            root.actualBrightness = val;
            let ratio = root.maxBrightness > 0 ? (val / root.maxBrightness) : 0.0;
            root.brightness = Math.max(0.0, Math.min(1.0, ratio));

            if (root._initialized && val !== prevVal) {
                root.brightnessUpdated(root.brightness);
            }
        }
    }

    function check(): void {
        actualFile.reload();
        root._updateActual();
    }

    Timer {
        id: pollTimer
        interval: 180
        repeat: true
        running: true
        onTriggered: {
            actualFile.reload();
            root._updateActual();
        }
    }

    Timer {
        id: initTimer
        interval: 600
        running: true
        repeat: false
        onTriggered: {
            root._updateMax();
            root._updateActual();
            root._initialized = true;
        }
    }
}
