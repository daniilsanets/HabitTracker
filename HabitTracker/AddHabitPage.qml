import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    title: "Новая привычка"
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
        Text {
            text: "Создать"
            color: "white"
            font.bold: true
            font.pixelSize: 18
            anchors.centerIn: parent
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.85
        spacing: 25

        Text {
            text: "Что будем трекать?"
            color: "white"
            font.pixelSize: 24
            font.bold: true
        }

        // Поле ввода Названия
        TextField {
            id: nameField
            placeholderText: "Название (например, Бег)"
            Layout.fillWidth: true
            color: "white"
            background: Rectangle {
                color: appWindow.surfaceColor
                radius: 10
                border.width: 0
            }
            font.pixelSize: 16
            padding: 15
        }

        // Поле ввода Описания
        TextField {
            id: descField
            placeholderText: "Мотивация или детали..."
            Layout.fillWidth: true
            color: "white"
            background: Rectangle {
                color: appWindow.surfaceColor
                radius: 10
            }
            font.pixelSize: 16
            padding: 15
        }

        Item { height: 20 } // Отступ

        Button {
            Layout.fillWidth: true
            height: 50
            background: Rectangle {
                color: appWindow.accentColor
                radius: 12
            }
            contentItem: Text {
                text: "Сохранить привычку"
                color: "white"
                font.bold: true
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                if (nameField.text !== "") {
                    dbHandler.addHabit(nameField.text, descField.text)
                    stackView.pop()
                    stackView.currentItem.refreshList()
                }
            }
        }
    }
}
