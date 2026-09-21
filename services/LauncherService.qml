import QtQuick 2.15
import Quickshell

Item {
    id: root

    property bool isOpen: false
    property string searchQuery: ""
    property int selectedIndex: 0
    property var allApps: []
    property var filteredApps: []

    readonly property bool isCommandMode: searchQuery.trim().startsWith(">")
    readonly property string commandText: isCommandMode ? searchQuery.trim().substring(1).trim() : ""
    readonly property string userShell: {
        var sh = Quickshell.env("SHELL");
        return (sh && sh.length > 0) ? sh : "zsh";
    }

    signal opened()
    signal closed()

    Connections {
        target: (typeof DesktopEntries !== "undefined" && DesktopEntries.applications) ? DesktopEntries.applications : null
        function onValuesChanged() { root.reloadApps(); }
    }

    onSearchQueryChanged: {
        filterApps();
    }

    Component.onCompleted: {
        reloadApps();
    }

    function reloadApps() {
        if (typeof DesktopEntries === "undefined" || !DesktopEntries.applications || !DesktopEntries.applications.values) {
            allApps = [];
            filterApps();
            return;
        }
        var apps = DesktopEntries.applications.values;
        var list = [];
        for (var i = 0; i < apps.length; i++) {
            var a = apps[i];
            if (a && a.name && a.name.length > 0) {
                list.push(a);
            }
        }
        list.sort(function(a, b) {
            return a.name.localeCompare(b.name);
        });
        allApps = list;
        filterApps();
    }

    function filterApps() {
        var rawTrimmed = searchQuery.trim();
        var q = rawTrimmed.toLowerCase();

        // 1. Explicit command mode starting with ">"
        if (rawTrimmed.startsWith(">")) {
            var rawCmd = rawTrimmed.substring(1).trim();
            var cmdList = [];
            if (rawCmd.length > 0) {
                cmdList.push({
                    isCommand: true,
                    isTerminal: true,
                    name: "Run: " + rawCmd,
                    comment: "Execute in Kitty terminal (Enter)",
                    command: rawCmd,
                    iconGlyph: ""
                });
                cmdList.push({
                    isCommand: true,
                    isTerminal: false,
                    name: "Run in Background",
                    comment: "Execute detached in background via " + root.userShell,
                    command: rawCmd,
                    iconGlyph: ""
                });
            } else {
                cmdList.push({
                    isCommand: true,
                    isTerminal: true,
                    name: "Type shell command...",
                    comment: "e.g. ls, btop, uname -r, reboot",
                    command: "",
                    iconGlyph: ""
                });
            }
            filteredApps = cmdList;
            selectedIndex = 0;
            return;
        }

        // 2. Empty query: display all desktop apps
        if (q.length === 0) {
            filteredApps = allApps;
            selectedIndex = 0;
            return;
        }

        // 3. Search apps with match quality scoring
        var matches = [];
        for (var i = 0; i < allApps.length; i++) {
            var app = allApps[i];
            var nameLower = app.name ? app.name.toLowerCase() : "";
            var commentLower = app.comment ? app.comment.toLowerCase() : "";
            var genericLower = app.genericName ? app.genericName.toLowerCase() : "";
            var idLower = app.id ? app.id.toLowerCase() : "";

            var score = 0;
            if (nameLower === q) {
                score = 10000;
            } else if (nameLower.startsWith(q)) {
                score = 5000;
            } else if (nameLower.indexOf(q) !== -1) {
                score = 2000;
            } else if (idLower && idLower.indexOf(q) !== -1) {
                score = 1000;
            } else if (genericLower && genericLower.indexOf(q) !== -1) {
                score = 500;
            } else if (commentLower && commentLower.indexOf(q) !== -1) {
                score = 100;
            }

            if (score > 0) {
                matches.push({ app: app, score: score });
            }
        }

        matches.sort(function(a, b) {
            if (a.score !== b.score) return b.score - a.score;
            return a.app.name.localeCompare(b.app.name);
        });

        var result = [];
        for (var j = 0; j < matches.length; j++) {
            result.push(matches[j].app);
        }

        // 4. Always provide shell command execution options
        result.push({
            isCommand: true,
            isTerminal: true,
            name: "Run '" + rawTrimmed + "' in Terminal",
            comment: "Execute in Kitty terminal",
            command: rawTrimmed,
            iconGlyph: ""
        });
        result.push({
            isCommand: true,
            isTerminal: false,
            name: "Run '" + rawTrimmed + "' in Background",
            comment: "Execute detached via " + root.userShell,
            command: rawTrimmed,
            iconGlyph: ""
        });

        filteredApps = result;
        selectedIndex = 0;
    }

    function navigateUp() {
        if (filteredApps.length > 0) {
            selectedIndex = (selectedIndex - 1 + filteredApps.length) % filteredApps.length;
        }
    }

    function navigateDown() {
        if (filteredApps.length > 0) {
            selectedIndex = (selectedIndex + 1) % filteredApps.length;
        }
    }

    function activateSelected() {
        if (!filteredApps || filteredApps.length === 0) return;
        if (selectedIndex >= 0 && selectedIndex < filteredApps.length) {
            var item = filteredApps[selectedIndex];
            activateItem(item);
        }
    }

    function activateItem(item) {
        if (!item) return;
        if (item.isCommand) {
            if (item.command && item.command.trim().length > 0) {
                executeCommand(item.command, item.isTerminal);
            }
            close();
            return;
        }
        launchApp(item);
    }

    function launchApp(app) {
        if (app && typeof app.execute === "function") {
            app.execute();
            close();
        }
    }

    function executeCommand(cmd, isTerminal) {
        if (!cmd || cmd.trim().length === 0) return;
        var trimmed = cmd.trim();
        var shell = userShell;
        console.log("LauncherService: Executing ->", trimmed, "isTerminal:", isTerminal, "shell:", shell);
        if (isTerminal) {
            Quickshell.execDetached(["kitty", "-e", shell, "-c", trimmed + "; exec " + shell]);
        } else {
            Quickshell.execDetached([shell, "-c", trimmed + " &"]);
        }
    }

    function open() {
        searchQuery = "";
        selectedIndex = 0;
        isOpen = true;
        opened();
    }

    function close() {
        isOpen = false;
        searchQuery = "";
        closed();
    }

    function toggle() {
        if (isOpen) {
            close();
        } else {
            open();
        }
    }
}
