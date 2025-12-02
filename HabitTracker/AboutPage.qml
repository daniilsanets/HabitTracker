import QtQuick
import QtQuick.Controls

Page {
    background: Rectangle { color: appWindow.bgColor }

    header: Item {
        height: 60
        Text {
            text: "< Назад"
            color: appWindow.accentColor
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 20
            MouseArea { anchors.fill: parent; onClicked: stackView.pop() }
        }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width * 0.8
        spacing: 20

        Rectangle {
            width: 100; height: 100
            radius: 20
            color: appWindow.accentColor
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                text: "H"
                font.pixelSize: 50
                font.bold: true
                color: "white"
                anchors.centerIn: parent
            }
        }

        Text {
            text: "Habit Tracker"
            color: "white"
            font.bold: true
            font.pixelSize: 22
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Версия 2.1.0\nDesigned by Ракицкий Тимофей Группа Су-31"
            color: appWindow.subTextColor
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle { height: 1; width: parent.width; color: appWindow.surfaceColor }

        Text {
            text: "Современный трекер привычек, написанный на C++ и Qt/QML. Позволяет отслеживать прогресс, вести календарь и анализировать статистику."
            color: "white"
            wrapMode: Text.WordWrap
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
