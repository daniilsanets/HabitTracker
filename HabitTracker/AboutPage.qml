import QtQuick
import QtQuick.Controls

Page {
    title: "О программе"

    header: ToolBar {
        ToolButton {
            text: "<"
            onClicked: stackView.pop()
        }
        Label {
            text: "О программе"
            anchors.centerIn: parent
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 10
        width: parent.width * 0.9

        Text {
            text: "Habit Tracker v1.0"
            font.bold: true
            font.pointSize: 18
        }

        Text {
            text: "Автор: Ваше Имя\nГруппа: Ваша Группа"
        }

        Text {
            wrapMode: Text.WordWrap
            width: parent.width
            text: "Задание: Написать мобильное приложение для информационной системы. " +
                  "Программа помогает отслеживать выполнение ежедневных привычек. " +
                  "Хранение истории в БД."
        }
    }
}
