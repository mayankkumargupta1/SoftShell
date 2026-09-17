import QtQuick 2.15
import Quickshell
import Quickshell.Services.Notifications
import "../theme"

Item {
    id: root

    // Reactive models
    ListModel { id: historyModel }
    readonly property alias history: historyModel
    property int totalCount: 0
    property bool hasNotifications: false

    // Collapsed banner queue state
    property var activeBanner: null
    property bool hasActiveBanner: false
    property var _bannerQueue: []
    property int bannerQueueCount: 0

    // Hover state forwarded from dynamic island (pauses banner auto-advance)
    property bool isIslandHovered: false

    onIsIslandHoveredChanged: {
        if (isIslandHovered) {
            // Pause timer while user is hovering over island so buttons remain clickable
            if (bannerTimer.running) {
                bannerTimer.stop();
            }
        } else {
            // Resume timer with fresh duration when cursor leaves island
            if (root.hasActiveBanner && !bannerTimer.running) {
                bannerTimer.interval = root._bannerQueue.length > 0 ? Theme.notifQueuedDuration : Theme.notifSingleDuration;
                bannerTimer.restart();
            }
        }
    }

    // Unique ID counter
    property int _idCounter: 1000

    // Banner display timer (pauses when island is hovered)
    Timer {
        id: bannerTimer
        repeat: false
        onTriggered: root._advanceBanner()
    }

    // Connect to DBus NotificationServer when available
    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: (n) => {
            try {
                n.tracked = true;
                let notifObj = {
                    id: (n.id !== undefined && n.id !== 0) ? n.id : (++root._idCounter),
                    appName: n.appName ? String(n.appName) : "Notification",
                    summary: n.summary ? String(n.summary) : "",
                    body: n.body ? String(n.body) : "",
                    appIcon: n.appIcon ? String(n.appIcon) : "",
                    isPinned: false,
                    timestamp: Date.now(),
                    timeStr: "Just now"
                };
                root._handleIncoming(notifObj);
            } catch (err) {
                console.warn("[NotificationService] Error in onNotification:", err);
            }
        }
    }

    // Push an incoming notification into history and banner queue
    function _handleIncoming(notif) {
        try {
            // 1. Add to top of history
            historyModel.insert(0, {
                id: notif.id,
                appName: notif.appName,
                summary: notif.summary,
                body: notif.body,
                appIcon: notif.appIcon,
                isPinned: notif.isPinned,
                timestamp: notif.timestamp,
                timeStr: notif.timeStr
            });
            root.totalCount = historyModel.count;
            root.hasNotifications = historyModel.count > 0;

            // 2. Queue for collapsed banner presentation
            if (root.activeBanner === null) {
                root.activeBanner = notif;
                root.hasActiveBanner = true;
                if (!root.isIslandHovered) {
                    bannerTimer.interval = root._bannerQueue.length > 0 ? Theme.notifQueuedDuration : Theme.notifSingleDuration;
                    bannerTimer.restart();
                }
            } else {
                root._bannerQueue.push(notif);
                root.bannerQueueCount = root._bannerQueue.length;
                if (!root.isIslandHovered && bannerTimer.running && bannerTimer.interval > Theme.notifQueuedDuration) {
                    bannerTimer.interval = Theme.notifQueuedDuration;
                }
            }
        } catch (err) {
            console.warn("[NotificationService] Error in _handleIncoming:", err);
        }
    }

    function _advanceBanner() {
        if (root._bannerQueue.length > 0) {
            root.activeBanner = root._bannerQueue.shift();
            root.bannerQueueCount = root._bannerQueue.length;
            root.hasActiveBanner = true;
            if (!root.isIslandHovered) {
                bannerTimer.interval = root._bannerQueue.length > 0 ? Theme.notifQueuedDuration : Theme.notifSingleDuration;
                bannerTimer.restart();
            }
        } else {
            root.activeBanner = null;
            root.bannerQueueCount = 0;
            root.hasActiveBanner = false;
        }
    }

    // Public actions
    function dismiss(notifId) {
        for (let i = 0; i < historyModel.count; i++) {
            if (historyModel.get(i).id === notifId) {
                historyModel.remove(i, 1);
                break;
            }
        }
        root.totalCount = historyModel.count;
        root.hasNotifications = historyModel.count > 0;
        if (root.activeBanner && root.activeBanner.id === notifId) {
            bannerTimer.stop();
            root._advanceBanner();
        }
    }

    function togglePin(notifId) {
        for (let i = 0; i < historyModel.count; i++) {
            let item = historyModel.get(i);
            if (item.id === notifId) {
                historyModel.setProperty(i, "isPinned", !item.isPinned);
                break;
            }
        }
    }

    function clearAllUnpinned() {
        for (let i = historyModel.count - 1; i >= 0; i--) {
            if (!historyModel.get(i).isPinned) {
                historyModel.remove(i, 1);
            }
        }
        root.totalCount = historyModel.count;
        root.hasNotifications = historyModel.count > 0;
        root._bannerQueue = [];
        root.bannerQueueCount = 0;
        root.activeBanner = null;
        root.hasActiveBanner = false;
        bannerTimer.stop();
    }

    function emitTestNotification(appName, summary, body, appIcon) {
        root._handleIncoming({
            id: ++root._idCounter,
            appName: appName || "Telegram",
            summary: summary || "Alex Morgan",
            body: body || "Hey! Are we still meeting at 3 PM today?",
            appIcon: appIcon || "",
            isPinned: false,
            timestamp: Date.now(),
            timeStr: "Just now"
        });
    }

    function _seedHistory(notif) {
        historyModel.append({
            id: notif.id || ++root._idCounter,
            appName: notif.appName,
            summary: notif.summary,
            body: notif.body,
            appIcon: notif.appIcon || "",
            isPinned: notif.isPinned || false,
            timestamp: notif.timestamp || Date.now(),
            timeStr: notif.timeStr || "Just now"
        });
        root.totalCount = historyModel.count;
        root.hasNotifications = historyModel.count > 0;
    }

    // Startup: clean empty state, ready for live system notifications
    Component.onCompleted: {
        root.totalCount = 0;
        root.hasNotifications = false;
    }
}
