import QtQuick 2.15

Item {
    id: root

    // Formatted time outputs
    property string time12: "12:00:00"
    property string amPm: "AM"
    property string time12Full: "12:00:00 AM"
    property string time12Compact: "12:00 AM"

    // Formatted date outputs
    property string dateFull: "Thursday, September 17"
    property string dateShort: "Thu, Sep 17"

    readonly property var _days: [
        "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
    ]
    readonly property var _months: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    function updateTime() {
        let now = new Date();
        let rawHours = now.getHours();
        let minutes = now.getMinutes();
        let seconds = now.getSeconds();

        let period = rawHours >= 12 ? "PM" : "AM";
        let hours12 = rawHours % 12;
        hours12 = hours12 ? hours12 : 12;

        let hStr = hours12 < 10 ? "0" + hours12 : "" + hours12;
        let mStr = minutes < 10 ? "0" + minutes : "" + minutes;
        let sStr = seconds < 10 ? "0" + seconds : "" + seconds;

        root.time12 = hStr + ":" + mStr + ":" + sStr;
        root.amPm = period;
        root.time12Full = root.time12 + " " + period;
        root.time12Compact = hStr + ":" + mStr + " " + period;

        let dayName = _days[now.getDay()];
        let monthName = _months[now.getMonth()];
        let dayNum = now.getDate();

        root.dateFull = dayName + ", " + monthName + " " + dayNum;
        root.dateShort = dayName.substring(0, 3) + ", " + monthName.substring(0, 3) + " " + dayNum;
    }

    Timer {
        id: ticker
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateTime()
    }

    Component.onCompleted: updateTime()
}
