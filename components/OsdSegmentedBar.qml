import QtQuick 2.15

// OsdSegmentedBar — 16-segment horizontal tick bar indicator matching SoftShell reference design
Item {
    id: root

    property real value: 0.0          // Normalized 0.0 to 1.0
    property int totalSegments: 16    // Standard 16 discrete blocks
    property bool isMuted: false      // When true, all segments display in muted/inactive state

    implicitWidth: segmentsRow.implicitWidth
    implicitHeight: 7

    readonly property int activeCount: isMuted ? 0 : Math.round(Math.max(0.0, Math.min(1.0, value)) * totalSegments)

    Row {
        id: segmentsRow
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: root.totalSegments

            Rectangle {
                width: 7
                height: 7
                radius: 1.2
                antialiasing: true

                readonly property bool isActive: index < root.activeCount

                color: isActive ? "#ffffff" : Qt.rgba(1, 1, 1, 0.18)

                Behavior on color {
                    ColorAnimation { duration: 80 }
                }
            }
        }
    }
}
