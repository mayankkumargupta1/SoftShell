import QtQuick 2.15
import Quickshell
import Quickshell.Io

// NetworkService — Manages Wi-Fi status, scanning, connections, and ethernet state.
// Non-blocking asynchronous interaction with scripts/network.sh via Quickshell Process.
Item {
    id: root

    property bool wifiEnabled: true
    property var activeWifi: null
    property var nearbyNetworks: []
    property var knownNetworks: []
    property var ethernet: ({ "device": "eth0", "state": "unavailable" })

    property bool isScanning: false
    property bool isConnecting: false
    property string connectingSsid: ""
    property string connectError: ""

    signal connectionFinished(bool success, string error)

    readonly property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/scripts/network.sh"

    Component.onCompleted: {
        refreshStatus();
        scanNetworks();
    }

    // Periodic refresh
    Timer {
        interval: 6000
        running: true
        repeat: true
        onTriggered: {
            root.refreshStatus();
        }
    }

    function refreshStatus() {
        statusProc.running = false;
        statusProc.command = [root.scriptPath, "status"];
        statusProc.running = true;
    }

    function scanNetworks() {
        if (!root.wifiEnabled) return;
        root.isScanning = true;
        scanProc.running = false;
        scanProc.command = [root.scriptPath, "scan"];
        scanProc.running = true;
    }

    function toggleWifi(enabled) {
        root.wifiEnabled = enabled;
        if (!enabled) {
            root.activeWifi = null;
            root.nearbyNetworks = [];
        }
        toggleProc.running = false;
        toggleProc.command = [root.scriptPath, "toggle-wifi", enabled ? "on" : "off"];
        toggleProc.running = true;
    }

    function connectToNetwork(ssid, password) {
        root.isConnecting = true;
        root.connectingSsid = ssid;
        root.connectError = "";
        let cmd = [root.scriptPath, "connect", ssid];
        if (password && password.length > 0) {
            cmd.push(password);
        }
        connectProc.running = false;
        connectProc.command = cmd;
        connectProc.running = true;
    }

    function forgetNetwork(ssid) {
        forgetProc.running = false;
        forgetProc.command = [root.scriptPath, "forget", ssid];
        forgetProc.running = true;
    }

    function disconnectWifi() {
        disconnectProc.running = false;
        disconnectProc.command = [root.scriptPath, "disconnect"];
        disconnectProc.running = true;
    }

    // 1. Status Process
    Process {
        id: statusProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    let obj = JSON.parse(data.trim());
                    if (obj.wifiEnabled !== undefined) root.wifiEnabled = obj.wifiEnabled;
                    root.activeWifi = obj.activeWifi || null;
                    if (obj.knownNetworks) root.knownNetworks = obj.knownNetworks;
                    if (obj.ethernet) root.ethernet = obj.ethernet;
                } catch(e) {}
            }
        }
    }

    // 2. Scan Process
    Process {
        id: scanProc
        stdout: SplitParser {
            onRead: data => {
                root.isScanning = false;
                try {
                    let list = JSON.parse(data.trim());
                    if (Array.isArray(list)) {
                        root.nearbyNetworks = list;
                    }
                } catch(e) {}
            }
        }
        onExited: {
            root.isScanning = false;
        }
    }

    // 3. Toggle Wi-Fi Process
    Process {
        id: toggleProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    let obj = JSON.parse(data.trim());
                    if (obj.wifiEnabled !== undefined) root.wifiEnabled = obj.wifiEnabled;
                    if (root.wifiEnabled) root.scanNetworks();
                } catch(e) {}
            }
        }
    }

    // 4. Connect Process
    Process {
        id: connectProc
        stdout: SplitParser {
            onRead: data => {
                root.isConnecting = false;
                root.connectingSsid = "";
                try {
                    let res = JSON.parse(data.trim());
                    if (res.success) {
                        root.connectError = "";
                        root.connectionFinished(true, "");
                        root.refreshStatus();
                        root.scanNetworks();
                    } else {
                        root.connectError = res.error || "Connection failed";
                        root.connectionFinished(false, root.connectError);
                    }
                } catch(e) {
                    root.connectError = "Unexpected response";
                    root.connectionFinished(false, root.connectError);
                }
            }
        }
        onExited: {
            root.isConnecting = false;
        }
    }

    // 5. Forget Process
    Process {
        id: forgetProc
        stdout: SplitParser {
            onRead: data => {
                root.refreshStatus();
                root.scanNetworks();
            }
        }
    }

    // 6. Disconnect Process
    Process {
        id: disconnectProc
        stdout: SplitParser {
            onRead: data => {
                root.refreshStatus();
                root.scanNetworks();
            }
        }
    }
}
