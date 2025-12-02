import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page
    background: Rectangle { color: appWindow.bgColor }

    function refreshList() {
        habitModel.clear()
        var list = dbHandler.getHabits()
        for (var i = 0; i < list.length; i++) {
            var parts = list[i].split(":")
            var id = parseInt(parts[0])
            var name = parts[1]
            var desc = parts.length > 2 ? parts[2] : ""
            // Получаем частоту (она теперь в конце строки)
            var freq = parts.length > 3 ? parseInt(parts[3]) : 0

            var isDone = dbHandler.isHabitCompletedToday(id)
            habitModel.append({
                "habitId": id,
                "name": name,
                "description": desc,
                "frequency": freq,
                "done": isDone
            })
        }
    }

    function getDateLabel(index) {
        var date = new Date()
        date.setDate(date.getDate() - (6 - index))
        return date.getDate().toString()
    }
    function getDayName(index) {
        var days = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"];
        var date = new Date();
        date.setDate(date.getDate() - (6 - index));
        return days[date.getDay()];
    }

    Component.onCompleted: refreshList()

    header: Column {
        width: parent.width; spacing: 20; padding: 20; topPadding: 30
        Label { text: "Мои привычки"; font.pixelSize: 32; font.bold: true; color: appWindow.textColor }
        RowLayout {
            spacing: 8; Layout.fillWidth: true
            Repeater {
                model: 7
                delegate: Rectangle {
                    Layout.preferredWidth: (page.width - 40 - (8 * 6)) / 7; Layout.preferredHeight: 65
                    radius: 14; color: index === 6 ? appWindow.accentColor : appWindow.surfaceColor
                    Column {
                        anchors.centerIn: parent; spacing: 4
                        Text { text: getDayName(index); color: index === 6 ? "white" : appWindow.subTextColor; font.pixelSize: 11; font.bold: true }
                        Text { text: getDateLabel(index); color: "white"; font.bold: true; font.pixelSize: 16 }
                    }
                }
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        clip: true; spacing: 12; topMargin: 10; bottomMargin: 100
        model: ListModel { id: habitModel }

        delegate: Rectangle {
            width: listView.width * 0.9
            height: Math.max(75, contentLayout.implicitHeight + 30)
            radius: 18
            color: appWindow.surfaceColor
            anchors.horizontalCenter: parent.horizontalCenter

            // Область нажатия для редактирования (на всю карточку, кроме чекбокса)
            MouseArea {
                anchors.fill: parent
                // Исключаем область справа, где чекбокс (примерно 60 пикселей)
                width: parent.width - 60
                onClicked: {
                    // Открываем страницу добавления в режиме РЕДАКТИРОВАНИЯ
                    stackView.push("AddHabitPage.qml", {
                        habitId: model.habitId,
                        initialName: model.name,
                        initialDesc: model.description,
                        initialFreq: model.frequency
                    })
                    // Обновляем список, когда вернемся назад
                    stackView.currentItem.onClosing.connect(refreshList)
                }
            }

            RowLayout {
                id: contentLayout
                anchors.fill: parent; anchors.margins: 15; spacing: 15

                ColumnLayout {
                    Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 4

                    // Верхняя строка: Название и метка частоты
                    RowLayout {
                        Text {
                            text: model.name
                            font.pixelSize: 16; font.bold: true
                            color: model.done ? "#66FFFFFF" : appWindow.textColor
                            font.strikeout: model.done
                            Layout.fillWidth: true; wrapMode: Text.Wrap
                        }
                        // Метка "Еженедельно", если выбрано
                        Rectangle {
                            visible: model.frequency === 1
                            color: "#3A3A4C"; radius: 4
                            width: 70; height: 18
                            Text {
                                anchors.centerIn: parent
                                text: "Еженедельно"; color: "#AAAAAA"; font.pixelSize: 9
                            }
                        }
                    }

                    Text {
                        text: model.description
                        font.pixelSize: 13; color: appWindow.subTextColor
                        visible: text !== ""; Layout.fillWidth: true; wrapMode: Text.WordWrap
                    }
                }

                // Разделитель
                Rectangle { width: 1; height: 30; color: "#404050"; Layout.alignment: Qt.AlignVCenter }

                // Чекбокс
                Rectangle {
                    width: 34; height: 34; radius: 12
                    color: model.done ? appWindow.accentColor : "transparent"
                    border.color: model.done ? appWindow.accentColor : "#404050"
                    border.width: 2; Layout.alignment: Qt.AlignVCenter

                    Text { anchors.centerIn: parent; text: "✓"; color: "white"; font.bold: true; visible: model.done }
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
        }
    }

    footer: Rectangle {
        height: 80; color: appWindow.surfaceColor
        Rectangle { width: parent.width; height: 1; color: "#FFFFFF"; opacity: 0.05; anchors.top: parent.top }
        RowLayout {
            anchors.fill: parent; spacing: 0
            Item { Layout.fillWidth: true; Layout.fillHeight: true; MouseArea { anchors.fill: parent; onClicked: stackView.push("StatsPage.qml") } Column { anchors.centerIn: parent; spacing: 4; Text { text: "📊"; font.pixelSize: 20; anchors.horizontalCenter: parent.horizontalCenter } Text { text: "Статистика"; color: appWindow.subTextColor; font.pixelSize: 10; anchors.horizontalCenter: parent.horizontalCenter } } }
            Item { Layout.fillWidth: true; Layout.fillHeight: true; Rectangle { width: 56; height: 56; radius: 28; color: appWindow.accentColor; anchors.centerIn: parent; anchors.verticalCenterOffset: -15; layer.enabled: true; Text { text: "+"; color: "white"; font.pixelSize: 32; anchors.centerIn: parent; anchors.verticalCenterOffset: -2 } MouseArea { anchors.fill: parent; onClicked: { stackView.push("AddHabitPage.qml"); stackView.currentItem.onClosing.connect(refreshList) } } } }
            Item { Layout.fillWidth: true; Layout.fillHeight: true; MouseArea { anchors.fill: parent; onClicked: stackView.push("AboutPage.qml") } Column { anchors.centerIn: parent; spacing: 4; Text { text: "ℹ️"; font.pixelSize: 20; anchors.horizontalCenter: parent.horizontalCenter } Text { text: "Инфо"; color: appWindow.subTextColor; font.pixelSize: 10; anchors.horizontalCenter: parent.horizontalCenter } } }
        }
    }
}
