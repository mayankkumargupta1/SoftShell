import QtQuick 2.15
import "../../theme"

// WallpaperThumb — Single wallpaper preview tile for the Edit popover picker.
// Renders a downscaled image, or a film glyph placeholder for videos / decode errors.
Item {
    id: root

    // 1. Public interface
    property string path: ""
    property bool isCurrent: false
    signal clicked()

    // 2. Geometry & Layout
    implicitWidth: 64
    implicitHeight: 40

    // 3. Internal state
    readonly property string _ext: root.path.substring(root.path.lastIndexOf(".") + 1).toLowerCase()
    readonly property bool _isVideo: root._ext === "mp4" || root._ext === "webm"
    readonly property bool _placeholder: root._isVideo || preview.status === Image.Error
    readonly property int _borderWidth: root.isCurrent ? 2 : (hover.hovered ? 1 : 0)

    // 6. Child Elements / Visual Tree
    Rectangle {
        id: frame
        anchors.fill: parent
        radius: 4
        antialiasing: true
        clip: true
        color: Theme.popoverCardBg
        border.width: root._borderWidth
        border.color: root.isCurrent ? Theme.accentBlue : Theme.popoverBorder

        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

        Image {
            id: preview
            anchors.fill: parent
            anchors.margins: root._borderWidth
            visible: !root._placeholder
            // Decode at 2x the display size so multi-megapixel sources never
            // land in memory at full resolution for every tile in the strip.
            sourceSize.width: 128
            sourceSize.height: 80
            source: (root.path === "" || root._isVideo) ? "" : "file://" + root.path
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            clip: true
        }

        Text {
            anchors.centerIn: parent
            visible: root._placeholder
            text: "󰈫"
            font.family: Theme.iconFontFamily
            font.pixelSize: 16
            color: Theme.textPrimary
            renderType: Text.NativeRendering
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
