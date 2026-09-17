import QtQuick
import QtQuick.Shapes
import "../theme"

Item {
    id: root

    // Public properties
    property color fillColor: Theme.islandBg
    property real radius: Theme.launcherRadius
    property real fillet: Theme.launcherFillet
    readonly property alias bodyItem: body

    implicitWidth: Theme.launcherWidth
    implicitHeight: Theme.launcherMaxHeight

    // 1. Left Concave Ear Fillet (flaring left along bottom screen edge)
    Shape {
        id: leftEar
        anchors.right: body.left
        anchors.rightMargin: -0.5
        anchors.bottom: root.bottom
        width: root.fillet
        height: root.fillet
        z: 1
        preferredRendererType: Shape.CurveRenderer
        layer.enabled: true
        layer.smooth: true
        layer.samples: 4

        ShapePath {
            fillColor: root.fillColor
            strokeWidth: 0
            strokeColor: "transparent"

            startX: root.fillet
            startY: root.fillet

            // Vertical line up along rectangle left edge
            PathLine { x: root.fillet; y: 0 }

            // Concave curve down and left to bottom screen edge (0, fillet)
            PathCubic {
                x: 0
                y: root.fillet
                control1X: root.fillet
                control1Y: root.fillet * 0.55
                control2X: root.fillet * 0.45
                control2Y: root.fillet
            }

            // Horizontal line along bottom edge back to start
            PathLine { x: root.fillet; y: root.fillet }
        }
    }

    // 2. Center AMOLED Black Rectangle (Main Body)
    // Bottom-overflow technique: uses standard `radius` to prevent corner reset glitches
    Rectangle {
        id: body
        anchors.horizontalCenter: root.horizontalCenter
        anchors.bottom: root.bottom
        anchors.bottomMargin: -root.radius
        width: Math.max(0, root.width - (root.fillet * 2))
        height: root.height + root.radius
        radius: root.radius
        color: root.fillColor
        antialiasing: true
        z: 2
    }

    // 3. Right Concave Ear Fillet (flaring right along bottom screen edge)
    Shape {
        id: rightEar
        anchors.left: body.right
        anchors.leftMargin: -0.5
        anchors.bottom: root.bottom
        width: root.fillet
        height: root.fillet
        z: 1
        preferredRendererType: Shape.CurveRenderer
        layer.enabled: true
        layer.smooth: true
        layer.samples: 4

        ShapePath {
            fillColor: root.fillColor
            strokeWidth: 0
            strokeColor: "transparent"

            startX: 0
            startY: root.fillet

            // Vertical line up along rectangle right edge
            PathLine { x: 0; y: 0 }

            // Concave curve down and right to bottom screen edge (fillet, fillet)
            PathCubic {
                x: root.fillet
                y: root.fillet
                control1X: 0
                control1Y: root.fillet * 0.55
                control2X: root.fillet * 0.55
                control2Y: root.fillet
            }

            // Horizontal line along bottom edge back to (0, fillet)
            PathLine { x: 0; y: root.fillet }
        }
    }
}
