import QtQuick 2.15
import Quickshell
import Quickshell.Io

// WorkspaceNavService — Fetches active workspace and client layout
// for live miniature workspace previews across workspaces 1..10.
Item {
    id: root

    // Active workspace ID
    property int activeWorkspaceId: 1

    // Logical monitor bounds for scaling window coordinates
    property real screenWidth: 1440.0
    property real screenHeight: 900.0

    // Carousel page: 0 -> Workspaces 1..5, 1 -> Workspaces 6..10
    property int currentPage: 0

    // Windows grouped by workspace ID (1..10)
    // Structure: { "1": [ { at: [x,y], size: [w,h], class: "...", glyph: "..." } ], ... }
    property var windowsByWorkspace: ({})

    // Summary of primary app per workspace (e.g. { "1": "Brave", "2": "Antigravity" })
    property var appSummaryByWorkspace: ({})

    signal stateUpdated()

    // Helper: Map app class name to Nerd Font icon glyph
    function getAppGlyph(appClass: string): string {
        let c = (appClass || "").toLowerCase();
        if (c.indexOf("kitty") !== -1 || c.indexOf("term") !== -1 || c.indexOf("alacritty") !== -1 || c.indexOf("ghostty") !== -1) return "󰄛";
        if (c.indexOf("brave") !== -1 || c.indexOf("chrome") !== -1 || c.indexOf("firefox") !== -1 || c.indexOf("browser") !== -1) return "󰖟";
        if (c.indexOf("code") !== -1 || c.indexOf("antigravity") !== -1 || c.indexOf("vsc") !== -1) return "󰞷";
        if (c.indexOf("nautilus") !== -1 || c.indexOf("file") !== -1 || c.indexOf("thunar") !== -1) return "󰉋";
        if (c.indexOf("spotify") !== -1 || c.indexOf("music") !== -1) return "󰓇";
        if (c.indexOf("discord") !== -1 || c.indexOf("slack") !== -1 || c.indexOf("telegram") !== -1) return "󰙯";
        if (c.indexOf("postman") !== -1 || c.indexOf("datagrip") !== -1) return "󱂛";
        return "󰈔";
    }

    // Process: Query active workspace
    Process {
        id: wsProc
        command: ["hyprctl", "activeworkspace", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                let txt = this.text.trim();
                if (!txt || txt === "") return;
                try {
                    let data = JSON.parse(txt);
                    if (data && data.id) {
                        root.activeWorkspaceId = data.id;
                        // Automatically set page to fit the active workspace
                        if (root.activeWorkspaceId > 5) {
                            root.currentPage = 1;
                        }
                        root.stateUpdated();
                    }
                } catch (e) {}
            }
        }
    }

    // Process: Query all open client windows and their geometries
    Process {
        id: clientsProc
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                let txt = this.text.trim();
                if (!txt || txt === "") return;
                try {
                    let list = JSON.parse(txt);
                    if (!Array.isArray(list)) return;

                    let byWs = {};
                    let summary = {};
                    for (let i = 1; i <= 10; i++) {
                        byWs[i.toString()] = [];
                        summary[i.toString()] = "Empty";
                    }

                    for (let j = 0; j < list.length; j++) {
                        let win = list[j];
                        if (!win.workspace || !win.workspace.id) continue;
                        let wsId = win.workspace.id.toString();
                        if (!byWs[wsId]) byWs[wsId] = [];

                        let glyph = root.getAppGlyph(win.class);
                        byWs[wsId].push({
                            x: win.at && win.at.length > 0 ? win.at[0] : 0,
                            y: win.at && win.at.length > 1 ? win.at[1] : 0,
                            width: win.size && win.size.length > 0 ? win.size[0] : 100,
                            height: win.size && win.size.length > 1 ? win.size[1] : 100,
                            appClass: win.class || "App",
                            title: win.title || "",
                            glyph: glyph
                        });

                        // Set first or primary app as summary
                        if (summary[wsId] === "Empty" && win.class) {
                            summary[wsId] = win.class.replace(/-origin$/, "");
                        } else if (byWs[wsId].length > 1) {
                            summary[wsId] = byWs[wsId][0].appClass.replace(/-origin$/, "") + " (" + byWs[wsId].length + ")";
                        }
                    }

                    root.windowsByWorkspace = byWs;
                    root.appSummaryByWorkspace = summary;
                    root.stateUpdated();
                } catch (e) {}
            }
        }
    }

    // Refresh data asynchronously
    function refresh(): void {
        wsProc.running = false;
        wsProc.running = true;
        clientsProc.running = false;
        clientsProc.running = true;
    }

    // Switch to workspace in Hyprland
    function goToWorkspace(wsId: int): void {
        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", wsId.toString()]);
        root.activeWorkspaceId = wsId;
    }

    function nextPage(): void {
        if (root.currentPage < 1) root.currentPage++;
    }

    function prevPage(): void {
        if (root.currentPage > 0) root.currentPage--;
    }
}
