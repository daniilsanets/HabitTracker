import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page
    background: Rectangle { color: appWindow.bgColor }

    // --- ЛОГИКА ---

    function refreshList() {
        habitModel.clear()
        var list = dbHandler.getHabits()
        for (var i = 0; i < list.length; i++) {
            var parts = list[i].split(":")
            var id = parseInt(parts[0])
            var name = parts[1]
            var desc = parts.length > 2 ? parts[2] : ""
            var isDone = dbHandler.isHabitCompletedToday(id)
            habitModel.append({ "habitId": id, "name": name, "description": desc, "done": isDone })
        }
    }

    // Функция для получения правильной даты (убирает баг с отрицательными числами)
    function getDateLabel(index) {
        var date = new Date()
        // Отнимаем дни от текущей даты. (6 - index) превращает индекс 6 в 0 (сегодня), а 0 в 6 (неделю назад)
        date.setDate(date.getDate() - (6 - index))
        return date.getDate().toString()
    }

    function getDayName(index) {
        // Массив дней недели для сдвига
        var days = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"];
        var date = new Date();
        date.setDate(date.getDate() - (6 - index));
        return days[date.getDay()];
    }

    Component.onCompleted: refreshList()

    // --- ВЕРХНЯЯ ЧАСТЬ (Header + Calendar) ---
    header: Column {
        width: parent.width
        spacing: 20
        padding: 20
        topPadding: 30 // Чуть больше воздуха сверху

        Label {
            text: "Мои привычки"
            font.pixelSize: 32 // Увеличили заголовок
            font.bold: true
            color: appWindow.textColor
        }

        // Календарь
        RowLayout {
            spacing: 8
            Layout.fillWidth: true

            Repeater {
                model: 7
                delegate: Rectangle {
                    // Адаптивная ширина: (ширина экрана - отступы) / 7 дней
                    Layout.preferredWidth: (page.width - 40 - (8 * 6)) / 7
                    Layout.preferredHeight: 65
                    radius: 14

                    // Если это сегодня (index 6) - цвет акцентный, иначе темный
                    color: index === 6 ? appWindow.accentColor : appWindow.surfaceColor

                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: getDayName(index)
                            color: index === 6 ? "white" : appWindow.subTextColor
                            font.pixelSize: 11
                            font.bold: true
                        }
                        Text {
                            text: getDateLabel(index) // Вызов исправленной функции
                            color: "white"
                            font.bold: true
                            font.pixelSize: 16
                        }
                    }
                }
            }
        }
    }

    // --- СПИСОК ПРИВЫЧЕК ---
    ListView {
        id: listView
        anchors.fill: parent
        clip: true
        spacing: 12
        topMargin: 10
        bottomMargin: 100 // Отступ снизу, чтобы контент не перекрывался меню
        model: ListModel { id: habitModel }

        delegate: Rectangle {
            width: listView.width * 0.9
            height: 75
            radius: 18
            color: appWindow.surfaceColor
            anchors.horizontalCenter: parent.horizontalCenter

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // Текст привычки
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: model.name
                        font.pixelSize: 16
                        font.bold: true
                        // Цвет тускнеет, если выполнено
                        color: model.done ? "#66FFFFFF" : appWindow.textColor
                        font.strikeout: model.done
                    }
                    Text {
                        text: model.description
                        font.pixelSize: 12
                        color: appWindow.subTextColor
                        visible: text !== ""
                        elide: Text.ElideRight
                    }
                }

                // Чекбокс (Кнопка выполнения)
                Rectangle {
                    width: 34; height: 34
                    radius: 12
                    color: model.done ? appWindow.accentColor : "transparent"
                    border.color: model.done ? appWindow.accentColor : "#404050"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "✓"
                        color: "white"
                        font.bold: true
                        visible: model.done
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
            }

            // Удаление по долгому нажатию (опционально) или можно добавить кнопку
            MouseArea {
                anchors.fill: parent
                z: -1 // Чтобы не перекрывать чекбокс
                onPressAndHold: {
                     dbHandler.removeHabit(model.habitId)
                     refreshList()
                }
            }
        }
    }

    // --- НИЖНЯЯ НАВИГАЦИЯ (ИСПРАВЛЕННАЯ) ---
    footer: Rectangle {
        height: 80
        color: appWindow.surfaceColor // Фон панели навигации

        // Тень или разделитель сверху
        Rectangle { width: parent.width; height: 1; color: "#FFFFFF"; opacity: 0.05; anchors.top: parent.top }

        RowLayout {
            anchors.fill: parent
            spacing: 0 // Кнопки делят пространство поровну

            // Кнопка 1: Статистика
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                MouseArea {
                    anchors.fill: parent
                    onClicked: stackView.push("StatsPage.qml")
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "📊"
                        font.pixelSize: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "Статистика"
                        color: appWindow.subTextColor
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // Кнопка 2: Добавить (Центральная, большая)
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Круглая кнопка приподнятая над фоном
                Rectangle {
                    width: 56; height: 56
                    radius: 28
                    color: appWindow.accentColor
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -15 // Чуть приподнимаем вверх для стиля

                    // Тень кнопки (свечение)
                    layer.enabled: true

                    Text {
                        text: "+"
                        color: "white"
                        font.pixelSize: 32
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -2
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stackView.push("AddHabitPage.qml")
                            stackView.currentItem.onClosing.connect(refreshList)
                        }
                    }
                }
            }

            // Кнопка 3: Инфо
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                MouseArea {
                    anchors.fill: parent
                    onClicked: stackView.push("AboutPage.qml")
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "ℹ️"
                        font.pixelSize: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "Инфо"
                        color: appWindow.subTextColor
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
