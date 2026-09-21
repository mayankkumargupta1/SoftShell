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
    property bool wifiEnabled: true
    property bool ethernetConnected: false
    property string connectivity: "full" // full, limited, portal, none, unknown

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

    // WiFi & connectivity poll every 3.5s (fast ~30ms async probe)
    property var _wifiTimer: Timer {
        interval: 3500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            wifiProc.running = false;
            wifiProc.running = true;
        }
    }

    function refreshWifi() {
        wifiProc.running = false;
        wifiProc.running = true;
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
    // 6. WiFi SSID + Signal Quality + Connectivity State
    // -----------------------------------------------------------------------
    property var wifiProc: Process {
        command: ["sh", "-c",
            "RADIO=$(nmcli -t -f WIFI g 2>/dev/null); " +
            "CONN=$(nmcli -t -f CONNECTIVITY g 2>/dev/null); " +
            "LINE=$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes:' | head -1); " +
            "ETH=$(nmcli -t -f TYPE,STATE dev 2>/dev/null | grep '^ethernet:connected' | head -1); " +
            "SSID=''; SIG='0'; " +
            "if [ -n \"$LINE\" ]; then " +
            "  REST=\"${LINE#yes:}\"; " +
            "  SIG=\"${REST##*:}\"; " +
            "  SSID=\"${REST%:*}\"; " +
            "elif [ \"$RADIO\" = \"enabled\" ]; then " +
            "  ACT_CON=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep ':802-11-wireless' | head -1); " +
            "  if [ -n \"$ACT_CON\" ]; then " +
            "    SSID=\"${ACT_CON%:802-11-wireless*}\"; " +
            "    SIG='70'; " +
            "  fi; " +
            "fi; " +
            "echo \"${RADIO}||${CONN}||${ETH}||${SIG}||${SSID}\""]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let text = this.text.trim();
                    let parts = text.split("||");
                    if (parts.length >= 5) {
                        let radio = parts[0].trim();
                        let conn = parts[1].trim();
                        let eth = parts[2].trim();
                        let sig = parseInt(parts[3].trim());
                        let ssid = parts[4].trim();

                        root.wifiEnabled = (radio !== "disabled");
                        root.connectivity = conn || "full";
                        root.ethernetConnected = eth.length > 0;
                        root.wifiSsid = ssid;
                        root.wifiConnected = ssid.length > 0;
                        root.wifiSignalQuality = (!isNaN(sig) && sig >= 0) ? Math.min(100, sig) : 0;
                    }
                } catch(e) { console.warn("WIFI parse error:", e); }
            }
        }
    }
}
