import QtQuick
import QtQuick.Shapes
import "../theme"

Item {
    id: root

    // Public properties
    property color fillColor: Theme.islandBg
    property real radius: Theme.collapsedRadius
    property real fillet: Theme.collapsedFillet

    implicitWidth: Theme.notchCollapsedWidth
    implicitHeight: Theme.notchCollapsedHeight

    // 1. Left Concave Ear Fillet (outside the body, flaring left to top screen edge)
    Shape {
        id: leftEar
        anchors.right: body.left
        anchors.rightMargin: -0.5 // Subpixel overlap prevents hairline seams
        anchors.top: root.top
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
            startY: 0

            // Vertical line down along rectangle left edge
            PathLine { x: root.fillet; y: root.fillet }

            // Concave curve up and left to top screen edge (0, 0)
            PathCubic {
                x: 0
                y: 0
                control1X: root.fillet
                control1Y: root.fillet * 0.45
                control2X: root.fillet * 0.45
                control2Y: 0
            }

            // Horizontal line along top edge
            PathLine { x: root.fillet; y: 0 }
        }
    }

    // 2. Center AMOLED Black Rectangle (Main Body)
    // Top-overflow technique: uses standard `radius` to prevent Qt 6 corner radius reset glitches during animation
    Rectangle {
        id: body
        anchors.horizontalCenter: root.horizontalCenter
        anchors.top: root.top
        anchors.topMargin: -root.radius
        width: Math.max(0, root.width - (root.fillet * 2))
        height: root.height + root.radius
        radius: root.radius
        color: root.fillColor
        antialiasing: true
        z: 2
    }

    // 3. Right Concave Ear Fillet (outside the body, flaring right to top screen edge)
    Shape {
        id: rightEar
        anchors.left: body.right
        anchors.leftMargin: -0.5 // Subpixel overlap prevents hairline seams
        anchors.top: root.top
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
            startY: 0

            // Vertical line down along rectangle right edge
            PathLine { x: 0; y: root.fillet }

            // Concave curve up and right to top screen edge (fillet, 0)
            PathCubic {
                x: root.fillet
                y: 0
                control1X: 0
                control1Y: root.fillet * 0.45
                control2X: root.fillet * 0.55
                control2Y: 0
            }

            // Horizontal line along top edge back to (0, 0)
            PathLine { x: 0; y: 0 }
        }
    }
}
