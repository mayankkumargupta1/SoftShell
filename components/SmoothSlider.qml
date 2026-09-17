import QtQuick 2.15
import "../theme"

Item {
    id: root

    property real value: 0.0          // Range: 0.0 to 1.0
    property bool interactive: true
    property color trackColor: "#33ffffff"
    property color progressColor: Theme.textPrimary
    property color knobColor: "#ffffff"
    property int trackHeight: 4
    property int knobSize: 10

    signal seekRequested(real fraction)

    implicitWidth: 200
    implicitHeight: 16

    readonly property bool _isHovered: hoverHandler.hovered
    readonly property bool _isDragging: dragHandler.active

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: root._isHovered || root._isDragging ? root.trackHeight + 2 : root.trackHeight
        radius: height / 2
        antialiasing: true
        color: root.trackColor

        Behavior on height { NumberAnimation { duration: Theme.animFast } }

        Rectangle {
            id: progress
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(0, Math.min(parent.width, parent.width * root.value))
            radius: parent.radius
            antialiasing: true
            color: root.progressColor
        }
    }

    Rectangle {
        id: knob
        x: Math.max(0, Math.min(root.width - width, (root.width * root.value) - (width / 2)))
        anchors.verticalCenter: parent.verticalCenter
        width: root._isHovered || root._isDragging ? root.knobSize + 2 : 0
        height: width
        radius: width / 2
        antialiasing: true
        color: root.knobColor
        opacity: root._isHovered || root._isDragging ? 1.0 : 0.0

        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        Behavior on width { NumberAnimation { duration: Theme.animFast } }
    }

    HoverHandler {
        id: hoverHandler
        enabled: root.interactive
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        enabled: root.interactive
        onTapped: function(eventPoint) {
            let frac = Math.max(0.0, Math.min(1.0, eventPoint.position.x / root.width));
            root.seekRequested(frac);
        }
    }

    DragHandler {
        id: dragHandler
        enabled: root.interactive
        target: null
        xAxis.enabled: true
        yAxis.enabled: false
        onActiveChanged: {
            if (!active) {
                let frac = Math.max(0.0, Math.min(1.0, centroid.position.x / root.width));
                root.seekRequested(frac);
            }
        }
    }
}
