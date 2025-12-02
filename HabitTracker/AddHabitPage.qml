import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: addPage
    background: Rectangle { color: appWindow.bgColor }

    // --- Свойства для РЕДАКТИРОВАНИЯ ---
    // Если habitId == -1, значит мы создаем новую. Если > -1, значит редактируем.
    property int habitId: -1
    property string initialName: ""
    property string initialDesc: ""
    property int initialFreq: 0 // 0 - Ежедневно, 1 - Еженедельно

    // При открытии страницы заполняем поля, если это редактирование
    Component.onCompleted: {
        if (habitId !== -1) {
            nameField.text = initialName
            descField.text = initialDesc
            freqCombo.currentIndex = initialFreq
        }
    }

    header: Item {
        height: 60
        Item {
            width: 80; height: parent.height; anchors.left: parent.left
            MouseArea { anchors.fill: parent; onClicked: stackView.pop() }
            RowLayout {
                anchors.centerIn: parent; spacing: 5
                Text { text: "‹"; color: appWindow.accentColor; font.pixelSize: 36; font.bold: true }
                Text { text: "Назад"; color: appWindow.accentColor; font.pixelSize: 16; font.bold: true }
            }
        }
        Text {
            // Меняем заголовок в зависимости от режима
            text: habitId === -1 ? "Новая привычка" : "Редактирование"
            color: "white"; font.bold: true; font.pixelSize: 18; anchors.centerIn: parent
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: parent.width
            spacing: 20
            anchors.margins: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Item { height: 10 }

            // Название
            ColumnLayout {
                Layout.fillWidth: true; spacing: 8
                Label { text: "НАЗВАНИЕ"; color: appWindow.subTextColor; font.pixelSize: 12; font.bold: true; Layout.leftMargin: 5 }
                TextField {
                    id: nameField
                    placeholderText: "Например: Спортзал"
                    placeholderTextColor: "#606070"
                    Layout.fillWidth: true; Layout.preferredHeight: 55
                    color: "white"; font.pixelSize: 16; leftPadding: 15
                    background: Rectangle {
                        color: appWindow.surfaceColor; radius: 12
                        border.color: nameField.activeFocus ? appWindow.accentColor : "transparent"; border.width: 2
                    }
                }
            }

            // Описание
            ColumnLayout {
                Layout.fillWidth: true; spacing: 8
                Label { text: "ОПИСАНИЕ"; color: appWindow.subTextColor; font.pixelSize: 12; font.bold: true; Layout.leftMargin: 5 }
                TextField {
                    id: descField
                    placeholderText: "Детали..."
                    placeholderTextColor: "#606070"
                    Layout.fillWidth: true; Layout.preferredHeight: 55
                    color: "white"; font.pixelSize: 16; leftPadding: 15
                    background: Rectangle {
                        color: appWindow.surfaceColor; radius: 12
                        border.color: descField.activeFocus ? appWindow.accentColor : "transparent"; border.width: 2
                    }
                }
            }

            // Выбор частоты (Ежедневно / Еженедельно)
            ColumnLayout {
                Layout.fillWidth: true; spacing: 8
                Label { text: "ПОВТОРЕНИЕ"; color: appWindow.subTextColor; font.pixelSize: 12; font.bold: true; Layout.leftMargin: 5 }

                ComboBox {
                    id: freqCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    model: ["Ежедневно", "Еженедельно"]
                    currentIndex: 0

                    // Кастомизация ComboBox под темную тему
                    delegate: ItemDelegate {
                        width: freqCombo.width
                        contentItem: Text {
                            text: modelData
                            color: "white"
                            font.pixelSize: 16
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle { color: appWindow.surfaceColor }
                        highlighted: freqCombo.highlightedIndex === index
                    }
                    contentItem: Text {
                        leftPadding: 15
                        text: freqCombo.displayText
                        font.pixelSize: 16
                        color: "white"
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: appWindow.surfaceColor
                        radius: 12
                        border.color: freqCombo.activeFocus ? appWindow.accentColor : "transparent"
                        border.width: 2
                    }
                }
            }

            Item { height: 20 }

            // Кнопка Сохранить (работает и для создания, и для обновления)
            Button {
                Layout.fillWidth: true; Layout.preferredHeight: 55
                background: Rectangle {
                    color: nameField.text.length > 0 ? appWindow.accentColor : "#3A3A4C"
                    radius: 16
                }
                contentItem: Text {
                    text: habitId === -1 ? "Создать" : "Сохранить изменения"
                    color: nameField.text.length > 0 ? "white" : "#808090"
                    font.bold: true; font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                enabled: nameField.text.length > 0
                onClicked: {
                    if (habitId === -1) {
                        // Режим создания
                        dbHandler.addHabit(nameField.text, descField.text, freqCombo.currentIndex)
                    } else {
                        // Режим редактирования
                        dbHandler.updateHabit(habitId, nameField.text, descField.text, freqCombo.currentIndex)
                    }
                    stackView.pop()
                    if (stackView.currentItem && stackView.currentItem.refreshList) {
                        stackView.currentItem.refreshList()
                    }
                }
            }

            // Кнопка УДАЛИТЬ (Видна только в режиме редактирования)
            Button {
                visible: habitId !== -1
                Layout.fillWidth: true; Layout.preferredHeight: 55
                background: Rectangle {
                    color: "transparent"
                    border.color: appWindow.dangerColor
                    border.width: 1
                    radius: 16
                }
                contentItem: Text {
                    text: "Удалить привычку"
                    color: appWindow.dangerColor
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    dbHandler.removeHabit(habitId)
                    stackView.pop()
                    if (stackView.currentItem && stackView.currentItem.refreshList) {
                        stackView.currentItem.refreshList()
                    }
                }
            }

            Item { height: 50 } // Отступ снизу
        }
    }
}
