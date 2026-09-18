import QtQuick 2.15
import "../../theme"

// BatteryTimelineItem — An individual vertical rounded capsule in the charge timeline
Item {
    id: root

    property var itemData: null
    signal hovered(var data, real xPos)
    signal unhovered()

    implicitWidth: 8
    implicitHeight: 28

    // Smoothly interpolate between Blue and Green based on percentage
    function computeColor(pct, state) {
        if (!pct && pct !== 0) pct = 100;
        let t = Math.max(0.0, Math.min(1.0, (pct - 20.0) / 80.0));

        // Blend from Blue rgb(10, 132, 255) at <=20% to Green rgb(48, 209, 88) at 100%
        let r = Math.round(10 + (48 - 10) * t);
        let g = Math.round(132 + (209 - 132) * t);
        let b = Math.round(255 - (255 - 88) * t);

        return Qt.rgba(r / 255.0, g / 255.0, b / 255.0, 1.0);
    }

    readonly property color baseColor: {
        if (!itemData) return "#30d158";
        return computeColor(itemData.percentage, itemData.state);
    }

    readonly property color topColor: Qt.lighter(baseColor, 1.22)
    readonly property color bottomColor: Qt.darker(baseColor, 1.08)

    Rectangle {
        id: capsule
        anchors.centerIn: parent
        width: itemHover.hovered ? 9 : 7
        height: itemHover.hovered ? 30 : 26
        radius: 3.5
        opacity: itemHover.hovered ? 1.0 : 0.90
        antialiasing: true

        gradient: Gradient {
            GradientStop { position: 0.0; color: root.topColor }
            GradientStop { position: 1.0; color: root.bottomColor }
        }

        Behavior on width { NumberAnimation { duration: 80 } }
        Behavior on height { NumberAnimation { duration: 80 } }
        Behavior on opacity { NumberAnimation { duration: 80 } }
    }

    HoverHandler {
        id: itemHover
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: {
            if (hovered) {
                root.hovered(root.itemData, root.x + root.width / 2);
            } else {
                root.unhovered();
            }
        }
    }
}
