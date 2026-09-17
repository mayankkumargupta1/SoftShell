import QtQuick 2.15
import "../../theme"
import "../../services"

Item {
    id: root

    property TimeService timeService: null
    property bool alignLeft: false

    implicitWidth: contentColumn.implicitWidth
    implicitHeight: contentColumn.implicitHeight

    Column {
        id: contentColumn
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: root.alignLeft ? parent.left : undefined
        anchors.horizontalCenter: root.alignLeft ? undefined : parent.horizontalCenter
        spacing: root.alignLeft ? 2 : 4

        // Line 1: Time
        Row {
            anchors.left: root.alignLeft ? parent.left : undefined
            anchors.horizontalCenter: root.alignLeft ? undefined : parent.horizontalCenter
            spacing: 6

            Text {
                id: timeText
                text: root.timeService ? root.timeService.time12 : "10:59:25"
                font.family: Theme.monoFontFamily
                font.pixelSize: root.alignLeft ? 22 : 26
                font.bold: true
                color: Theme.clockColor
                renderType: Text.NativeRendering
            }

            Text {
                id: amPmText
                visible: true
                text: root.timeService ? root.timeService.amPm : "AM"
                font.family: Theme.monoFontFamily
                font.pixelSize: root.alignLeft ? 12 : 14
                font.bold: true
                color: Theme.clockColor
                opacity: 0.85
                anchors.bottom: parent.bottom
                anchors.bottomMargin: root.alignLeft ? 3 : 4
                renderType: Text.NativeRendering
            }
        }

        // Line 2: Full Day & Date (e.g. Thursday, September 17)
        Text {
            id: dateText
            anchors.left: root.alignLeft ? parent.left : undefined
            anchors.horizontalCenter: root.alignLeft ? undefined : parent.horizontalCenter
            text: root.timeService ? root.timeService.dateFull : "Thursday, September 17"
            font.family: Theme.monoFontFamily
            font.pixelSize: root.alignLeft ? 11 : 13
            font.weight: 500
            color: Theme.clockColor
            opacity: 0.9
            renderType: Text.NativeRendering
        }
    }
}
