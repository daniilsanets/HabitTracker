import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page
    background: Rectangle { color: appWindow.bgColor }

    function refreshList() {
        habitModel.clear()
        var list = dbHandler.getHabits() // Формат "id:name:desc"
        for (var i = 0; i < list.length; i++) {
            var parts = list[i].split(":")
            var id = parseInt(parts[0])
            var name = parts[1]
            var desc = parts.length > 2 ? parts[2] : ""
            var isDone = dbHandler.isHabitCompletedToday(id)
            habitModel.append({ "habitId": id, "name": name, "description": desc, "done": isDone })
        }
    }

    Component.onCompleted: refreshList()

    // --- Заголовок и Календарь ---
    header: Column {
        width: parent.width
        spacing: 15
        padding: 20

        Label {
            text: "Мои привычки"
            font.pixelSize: 28
            font.bold: true
            color: appWindow.textColor
        }

        // Имитация ленты календаря (статичная для этой версии)
        RowLayout {
            spacing: 10
            Repeater {
                model: 7 // 7 дней
                delegate: Rectangle {
                    width: 40; height: 60
                    radius: 12
                    // Подсветка "сегодня" (последний элемент)
                    color: index === 6 ? appWindow.accentColor : appWindow.surfaceColor

                    Column {
                        anchors.centerIn: parent
                        Text {
                            // Простая логика дней недели
                            text: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"][index]
                            color: index === 6 ? "white" : appWindow.subTextColor
                            font.pixelSize: 10
                        }
                        Text {
                            text: (new Date().getDate() - 6 + index).toString() // Примерные даты
                            color: "white"
                            font.bold: true
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
    }

    // --- Список привычек ---
    ListView {
        id: listView
        anchors.fill: parent
        clip: true
        spacing: 15
        topMargin: 20
        model: ListModel { id: habitModel }

        delegate: Rectangle {
            width: listView.width * 0.9
            height: 80
            radius: 16
            color: appWindow.surfaceColor
            anchors.horizontalCenter: parent.horizontalCenter

            // Тень
            layer.enabled: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // Инфо о привычке
                ColumnLayout {
                    Layout.fillWidth: true
                    Text {
                        text: model.name
                        font.pixelSize: 18
                        font.bold: true
                        color: model.done ? appWindow.subTextColor : appWindow.textColor
                        // Зачеркивание если выполнено
                        font.strikeout: model.done
                    }
                    Text {
                        text: model.description
                        font.pixelSize: 12
                        color: appWindow.subTextColor
                        visible: text !== ""
                    }
                }

                // Кастомный чекбокс
                Rectangle {
                    width: 32; height: 32
                    radius: 16
                    color: model.done ? appWindow.accentColor : "transparent"
                    border.color: model.done ? appWindow.accentColor : appWindow.subTextColor
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "✓"
                        color: "white"
                        visible: model.done
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var newState = !model.done
                            dbHandler.checkHabit(model.habitId, newState)
                            model.done = newState
                        }
                    }
                }

                // Кнопка удаления (крестик)
                Text {
                    text: "✕"
                    color: appWindow.dangerColor
                    font.pixelSize: 18
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            dbHandler.removeHabit(model.habitId)
                            refreshList()
                        }
                    }
                }
            }
        }
    }

    // --- Плавающие кнопки внизу (FAB) ---
    footer: Item {
        height: 100
        RowLayout {
            anchors.centerIn: parent
            spacing: 20

            // Кнопка Статистики
            Button {
                background: Rectangle {
                    color: appWindow.surfaceColor
                    radius: 25
                    border.color: appWindow.accentColor
                }
                contentItem: Text {
                    text: "📊 Статистика"
                    color: appWindow.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: stackView.push("StatsPage.qml")
            }

            // Кнопка Добавления (большая яркая)
            Button {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 60
                background: Rectangle {
                    color: appWindow.accentColor
                    radius: 30
                    // Эффект свечения
                    layer.enabled: true
                }
                contentItem: Text {
                    text: "+"
                    font.pixelSize: 30
                    color: "white"
                    anchors.centerIn: parent
                }
                onClicked: {
                    stackView.push("AddHabitPage.qml")
                    stackView.currentItem.onClosing.connect(refreshList)
                }
            }

            // Кнопка О программе
            Button {
                 background: Rectangle {
                    color: appWindow.surfaceColor
                    radius: 25
                }
                contentItem: Text {
                    text: "ℹ️ Инфо"
                    color: appWindow.subTextColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: stackView.push("AboutPage.qml")
            }
        }
    }
}
