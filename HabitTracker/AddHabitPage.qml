import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    title: "Новая привычка"

    header: ToolBar {
        ToolButton {
            text: "< Назад"
            onClicked: stackView.pop()
        }
        Label {
            text: "Добавить привычку"
            anchors.centerIn: parent
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.8
        spacing: 20

        TextField {
            id: nameField
            placeholderText: "Название привычки"
            Layout.fillWidth: true
        }

        TextField {
            id: descField
            placeholderText: "Описание (необязательно)"
            Layout.fillWidth: true
        }

        Button {
            text: "Сохранить"
            Layout.fillWidth: true
            onClicked: {
                if (nameField.text !== "") {
                    dbHandler.addHabit(nameField.text, descField.text)
                    stackView.pop() // Вернуться назад
                    stackView.currentItem.refreshList() // Обновить список на главном экране
                }
            }
        }
    }
}
