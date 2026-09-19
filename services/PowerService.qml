import QtQuick 2.15
import Quickshell
import Quickshell.Io

// PowerService — Manages battery health metrics, power profiles, and display sleep timers.
// Interfaces asynchronously with scripts/power.sh (non-blocking).
Item {
    id: root

    // Battery Metrics
    property int percentage: 100
    property string state: "discharging"
    property bool isCharging: state === "charging"
    property string timeRemaining: "Calculating..."
    property string timeType: "Remaining"
    property real energyRate: 0.0
    property real voltage: 0.0
    property real health: 100.0
    property int cycles: 0
    property real energy: 0.0
    property real energyFull: 0.0
    property real energyDesign: 0.0
    property var significantApps: []

    readonly property string healthCategory: {
        if (health >= 95.0) return "Excellent";
        if (health >= 85.0) return "Good";
        if (health >= 75.0) return "Normal";
        if (health >= 60.0) return "Needs Help";
        return "Critical";
    }

    property var batteryHistory: []

    // Power Profiles (Dual Mode: on battery vs on power adapter)
    property string currentProfile: "balanced"
    property string onBatteryProfile: "balanced"
    property string onAcProfile: "performance"

    // Sleep & Dim Timers (in seconds)
    property int sleepTimeout: 600
    property int dimTimeout: 300

    readonly property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/scripts/power.sh"

    Component.onCompleted: {
        refreshStats();
        fetchProfile();
        fetchProfileModes();
        fetchHistory();
        fetchTimers();
    }

    // Timer to poll battery metrics every 3 seconds
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            root.refreshStats();
            root.fetchProfileModes();
        }
    }

    function refreshStats() {
        statsProc.running = true;
    }

    function fetchHistory() {
        historyProc.running = true;
    }

    function fetchProfile() {
        getProfileProc.running = true;
    }

    function fetchProfileModes() {
        getProfileModesProc.running = true;
    }

    function setProfile(name) {
        setProfileProc.command = [root.scriptPath, "set-profile", name];
        setProfileProc.running = true;
    }

    function setProfileMode(mode, name) {
        if (mode === "battery") root.onBatteryProfile = name;
        if (mode === "ac") root.onAcProfile = name;
        setProfileModeProc.running = false;
        setProfileModeProc.command = [root.scriptPath, "set-profile-mode", mode, name];
        setProfileModeProc.running = true;
    }

    function fetchTimers() {
        getTimersProc.running = true;
    }

    function setSleepTimeout(seconds) {
        setSleepProc.command = [root.scriptPath, "set-sleep", seconds.toString()];
        setSleepProc.running = true;
    }

    function setDimTimeout(seconds) {
        setDimProc.command = [root.scriptPath, "set-dim", seconds.toString()];
        setDimProc.running = true;
    }

    // 1. Battery Stats Process
    Process {
        id: statsProc
        command: [root.scriptPath, "stats"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let obj = JSON.parse(data.trim());
                    if (obj.percentage !== undefined) root.percentage = obj.percentage;
                    if (obj.state !== undefined) root.state = obj.state;
                    if (obj.timeRemaining !== undefined) root.timeRemaining = obj.timeRemaining;
                    if (obj.timeType !== undefined) root.timeType = obj.timeType;
                    if (obj.energyRate !== undefined) root.energyRate = obj.energyRate;
                    if (obj.voltage !== undefined) root.voltage = obj.voltage;
                    if (obj.health !== undefined) root.health = obj.health;
                    if (obj.cycles !== undefined) root.cycles = obj.cycles;
                    if (obj.energy !== undefined) root.energy = obj.energy;
                    if (obj.energyFull !== undefined) root.energyFull = obj.energyFull;
                    if (obj.energyDesign !== undefined) root.energyDesign = obj.energyDesign;
                    if (obj.significantApps !== undefined) root.significantApps = obj.significantApps;
                } catch(e) {}
            }
        }
    }

    // 2. Profile Processes
    Process {
        id: getProfileProc
        command: [root.scriptPath, "get-profile"]
        stdout: SplitParser {
            onRead: data => {
                let p = data.trim();
                if (p.length > 0) root.currentProfile = p;
            }
        }
    }

    Process {
        id: setProfileProc
        stdout: SplitParser {
            onRead: data => {
                let p = data.trim();
                if (p.length > 0) root.currentProfile = p;
            }
        }
    }

    // 3. Timers Processes
    Process {
        id: getTimersProc
        command: [root.scriptPath, "get-timers"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let obj = JSON.parse(data.trim());
                    if (obj.sleepTimeout !== undefined) root.sleepTimeout = obj.sleepTimeout;
                    if (obj.dimTimeout !== undefined) root.dimTimeout = obj.dimTimeout;
                } catch(e) {}
            }
        }
    }

    Process {
        id: setSleepProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    let obj = JSON.parse(data.trim());
                    if (obj.sleepTimeout !== undefined) root.sleepTimeout = obj.sleepTimeout;
                } catch(e) {}
            }
        }
    }

    Process {
        id: setDimProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    let obj = JSON.parse(data.trim());
                    if (obj.dimTimeout !== undefined) root.dimTimeout = obj.dimTimeout;
                } catch(e) {}
            }
        }
    }

    // 4. Battery History Process
    Process {
        id: historyProc
        command: [root.scriptPath, "history"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let arr = JSON.parse(data.trim());
                    if (Array.isArray(arr) && arr.length > 0) {
                        root.batteryHistory = arr;
                    }
                } catch(e) {}
            }
        }
    }

    // 5. Dual Profile Modes Processes
    Process {
        id: getProfileModesProc
        command: [root.scriptPath, "get-profile-modes"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let obj = JSON.parse(data.trim());
                    if (obj.onBattery) root.onBatteryProfile = obj.onBattery;
                    if (obj.onAc) root.onAcProfile = obj.onAc;
                    if (obj.current) root.currentProfile = obj.current;
                } catch(e) {}
            }
        }
    }

    Process {
        id: setProfileModeProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    let obj = JSON.parse(data.trim());
                    if (obj.onBattery) root.onBatteryProfile = obj.onBattery;
                    if (obj.onAc) root.onAcProfile = obj.onAc;
                    if (obj.current) root.currentProfile = obj.current;
                } catch(e) {}
            }
        }
    }
}
