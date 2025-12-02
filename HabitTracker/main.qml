import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 400
    height: 680
    visible: true
    title: qsTr("Habit Tracker")

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "HabitPage.qml"
    }
}
