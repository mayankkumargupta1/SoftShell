import QtQuick 2.15
import "../../theme"
import "../../services"

// WallpaperSection — Edit popover content for switching the desktop wallpaper.
// Renders prev/next link actions plus a scrollable thumbnail picker (no header).
Item {
    id: root

    // 1. Public interface
    signal requestClose()

    // 2. Geometry & Layout
    implicitHeight: col.implicitHeight

    // 3. Internal state
    // autoInit: false — BarWindow owns the primary instance; re-initialising here
    // would kill and respawn mpvpaper, re-applying the wallpaper on shell startup.
    readonly property WallpaperService _wallpapers: WallpaperService {
        autoInit: false
    }
    readonly property string _currentBase: root._baseName(root._wallpapers.currentWallpaper)
    readonly property bool _hasWallpapers: root._wallpapers.wallpapers.length > 0

    function _baseName(path) {
        return path ? path.substring(path.lastIndexOf("/") + 1).trim() : "";
    }

    function _step(backwards) {
        if (backwards)
            root._wallpapers.prevWallpaper();
        else
            root._wallpapers.nextWallpaper();
    }

    // 4. Signal Handlers
    // The script writes its state file before announcing the change, so re-probing
    // on this signal always resolves the freshly applied absolute path.
    Connections {
        target: root._wallpapers
        function onWallpaperChanged(path) {
            root._wallpapers.refreshCurrent();
        }
    }

    // 6. Child Elements / Visual Tree
    Column {
        id: col
        width: root.width
        spacing: 6

        // Prev / Next link actions — the popover intentionally stays open so the
        // user can keep flipping through wallpapers.
        Item {
            width: parent.width
            height: 22

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Repeater {
                    model: [
                        { label: "Previous", backwards: true },
                        { label: "Next", backwards: false }
                    ]
                    delegate: Item {
                        width: linkLabel.implicitWidth + 12
                        height: 20

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            antialiasing: true
                            color: linkHover.hovered ? Theme.barItemHover : "transparent"
                        }

                        Text {
                            id: linkLabel
                            anchors.centerIn: parent
                            text: modelData.label
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: "#007aff"
                            renderType: Text.NativeRendering
                        }

                        HoverHandler {
                            id: linkHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: root._step(modelData.backwards)
                        }
                    }
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, parent.width * 0.5)
                text: root._currentBase
                elide: Text.ElideMiddle
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: Theme.appleSubtext
                renderType: Text.NativeRendering
            }
        }

        // Thumbnail strip — fixed height, horizontally scrollable
        ListView {
            x: 2
            width: parent.width - 4
            height: 44
            visible: root._hasWallpapers
            orientation: ListView.Horizontal
            spacing: 6
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root._wallpapers.wallpapers
            delegate: WallpaperThumb {
                path: modelData
                isCurrent: root._currentBase !== "" && root._baseName(modelData) === root._currentBase
                onClicked: root._wallpapers.setWallpaper(modelData)
            }
        }

        Text {
            leftPadding: 6
            bottomPadding: 4
            visible: !root._hasWallpapers
            text: "No wallpapers found"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: Theme.appleSubtext
            renderType: Text.NativeRendering
        }
    }
}
