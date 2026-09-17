import QtQuick 2.15
import Quickshell
import Quickshell.Io
import "../theme"

// SystemStatsService — polls CPU, RAM, Temperature, Battery and WiFi every 2 seconds.
// Uses Quickshell Process (non-blocking) to read /proc and sysfs files.
QtObject {
    id: root

    // --- Exposed Properties ---
    property int cpuPercent: 0
    property int ramPercent: 0
    property real ramUsedGb: 0.0
    property int cpuTempC: 0
    property int batteryPercent: 0
    property bool isCharging: false
    property bool wifiConnected: false
    property string wifiSsid: ""
    property int wifiSignalQuality: 0   // 0-100 quality scale

    // --- Internal CPU diff state ---
    property var _prevCpuIdle: -1
    property var _prevCpuTotal: -1

    // -----------------------------------------------------------------------
    // 1. Master Poll Timer — fires every 2 seconds
    // -----------------------------------------------------------------------
    property var _pollTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true;
            memProc.running = true;
            tempProc.running = true;
            batProc.running = true;
        }
    }

    // WiFi polls every 10s to avoid subprocess overhead
    property var _wifiTimer: Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: wifiProc.running = true
    }

    // -----------------------------------------------------------------------
    // 2. CPU Usage — /proc/stat diff
    // -----------------------------------------------------------------------
    property var cpuProc: Process {
        command: ["cat", "/proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let line = this.text.split("\n")[0];
                    let parts = line.trim().split(/\s+/);
                    let vals = parts.slice(1, 9).map(Number);
                    let idle  = vals[3] + vals[4];
                    let total = vals.reduce(function(a, b) { return a + b; }, 0);

                    if (root._prevCpuIdle >= 0) {
                        let dIdle  = idle  - root._prevCpuIdle;
                        let dTotal = total - root._prevCpuTotal;
                        root.cpuPercent = dTotal > 0 ? Math.round((1 - dIdle / dTotal) * 100) : 0;
                    }
                    root._prevCpuIdle  = idle;
                    root._prevCpuTotal = total;
                } catch(e) { console.warn("CPU parse error:", e); }
            }
        }
    }

    // -----------------------------------------------------------------------
    // 3. RAM Usage — /proc/meminfo
    // -----------------------------------------------------------------------
    property var memProc: Process {
        command: ["cat", "/proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let lines = this.text.split("\n");
                    let total = 0, available = 0;
                    for (let i = 0; i < lines.length; i++) {
                        if (lines[i].indexOf("MemTotal:") === 0)
                            total = parseInt(lines[i].split(/\s+/)[1]);
                        if (lines[i].indexOf("MemAvailable:") === 0)
                            available = parseInt(lines[i].split(/\s+/)[1]);
                    }
                    if (total > 0) {
                        root.ramPercent = Math.round((total - available) / total * 100);
                        root.ramUsedGb  = Math.round((total - available) / 1048576 * 10) / 10;
                    }
                } catch(e) { console.warn("MEM parse error:", e); }
            }
        }
    }

    // -----------------------------------------------------------------------
    // 4. CPU Temperature — x86_pkg_temp (thermal_zone9)
    // -----------------------------------------------------------------------
    property var tempProc: Process {
        command: ["cat", "/sys/class/thermal/thermal_zone9/temp"]
        stdout: StdioCollector {
            onStreamFinished: {
                let val = parseInt(this.text.trim());
                if (!isNaN(val)) root.cpuTempC = Math.round(val / 1000);
            }
        }
    }

    // -----------------------------------------------------------------------
    // 5. Battery — capacity and charging status
    // -----------------------------------------------------------------------
    property var batProc: Process {
        command: ["sh", "-c",
            "printf '%s:%s' \"$(cat /sys/class/power_supply/BAT0/capacity)\" " +
            "\"$(cat /sys/class/power_supply/BAT0/status)\""]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let parts = this.text.trim().split(":");
                    if (parts.length >= 2) {
                        root.batteryPercent = parseInt(parts[0]);
                        root.isCharging = parts[1].trim().toLowerCase() === "charging";
                    }
                } catch(e) { console.warn("BAT parse error:", e); }
            }
        }
    }

    // -----------------------------------------------------------------------
    // 6. WiFi SSID + Signal Quality
    // -----------------------------------------------------------------------
    property var wifiProc: Process {
        command: ["sh", "-c",
            "SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | head -1 | cut -d: -f2); " +
            "QUAL=$(awk 'NR==3{gsub(/\\./, \"\", $3); print $3}' /proc/net/wireless 2>/dev/null); " +
            "echo \"${SSID}||${QUAL}\""]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let text = this.text.trim();
                    let sep = text.indexOf("||");
                    if (sep >= 0) {
                        let ssid = text.substring(0, sep).trim();
                        let qualStr = text.substring(sep + 2).trim();
                        root.wifiSsid = ssid;
                        root.wifiConnected = ssid.length > 0;
                        let qual = parseInt(qualStr);
                        root.wifiSignalQuality = (!isNaN(qual) && qual > 0)
                            ? Math.min(100, Math.round(qual / 70 * 100))
                            : 0;
                    }
                } catch(e) { console.warn("WIFI parse error:", e); }
            }
        }
    }
}
