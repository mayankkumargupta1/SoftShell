import QtQuick 2.15
import "../../theme"
import "../../services"

Item {
    id: root

    property TimeService timeService: null

    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight

    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Text {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            text: root.timeService ? root.timeService.time12 : "10:46:15"
            font.family: Theme.monoFontFamily
            font.pixelSize: 13
            font.bold: true
            color: Theme.clockColor
            renderType: Text.NativeRendering
        }

        Text {
            id: amPmText
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            text: root.timeService ? root.timeService.amPm : "AM"
            font.family: Theme.monoFontFamily
            font.pixelSize: 10
            font.bold: true
            color: Theme.clockColor
            opacity: 0.8
            renderType: Text.NativeRendering
        }
    }
}
