import QtQuick 2.15
import "../theme"

Item {
    id: root

    property bool playing: true
    property color barColor: Theme.accentGreen
    property int barWidth: 3
    property int maxBarHeight: 14
    property int minBarHeight: 3
    property int spacing: 2

    implicitHeight: maxBarHeight
    implicitWidth: (barWidth * 4) + (spacing * 3)

    Row {
        anchors.fill: parent
        spacing: root.spacing

        Repeater {
            model: 4

            Rectangle {
                id: bar
                width: root.barWidth
                height: root.minBarHeight
                radius: root.barWidth / 2
                antialiasing: true
                color: root.barColor
                anchors.bottom: parent.bottom

                SequentialAnimation on height {
                    running: root.playing
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: index === 0 ? root.maxBarHeight * 0.75 :
                            index === 1 ? root.maxBarHeight :
                            index === 2 ? root.maxBarHeight * 0.55 : root.maxBarHeight * 0.85
                        duration: 250 + (index * 70)
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        to: root.minBarHeight
                        duration: 250 + (index * 70)
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }
}
