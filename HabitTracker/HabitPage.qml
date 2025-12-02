import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page
    background: Rectangle { color: appWindow.bgColor }

    property date selectedDate: new Date()

    // Переменная для направления анимации (-1 = влево, 1 = вправо)
    property int animDir: 0

    function parseSqlDate(dateStr) {
        if (!dateStr || dateStr === "") return new Date()
        var p = dateStr.split("-")
        return new Date(p[0], p[1] - 1, p[2])
    }

    function toSqlDate(d) {
        return d.getFullYear() + "-" +
               String(d.getMonth() + 1).padStart(2, '0') + "-" +
               String(d.getDate()).padStart(2, '0')
    }

    function getMonday(d) {
        var temp = new Date(d);
        var day = temp.getDay();
        var diff = temp.getDate() - day + (day === 0 ? -6 : 1);
        return new Date(temp.setDate(diff));
    }

    function refreshList() {
        habitModel.clear()
        var dateStr = toSqlDate(selectedDate)
        var list = dbHandler.getHabits(dateStr)

        for (var i = 0; i < list.length; i++) {
            var parts = list[i].split(":")
            var id = parseInt(parts[0])
            var name = parts[1]
            var desc = parts.length > 2 ? parts[2] : ""
            var freq = parts.length > 3 ? parseInt(parts[3]) : 0
            var createdStr = parts.length > 4 ? parts[4] : ""

            if (freq === 1) {
                var createdDate = parseSqlDate(createdStr)
                if (createdDate.getDay() !== selectedDate.getDay()) continue
            }

            var isDone = dbHandler.isHabitCompleted(id, dateStr)

            habitModel.append({
                "habitId": id, "name": name, "description": desc,
                "frequency": freq, "done": isDone
            })
        }
    }

    function getDateOfButton(index) {
        var monday = getMonday(selectedDate)
        var result = new Date(monday)
        result.setDate(monday.getDate() + index)
        return result
    }

    function isSelected(index) {
        return toSqlDate(getDateOfButton(index)) === toSqlDate(selectedDate)
    }

    function isToday(index) {
        var btnDate = getDateOfButton(index)
        var today = new Date()
        return toSqlDate(btnDate) === toSqlDate(today)
    }

    // --- ФУНКЦИИ ПЕРЕКЛЮЧЕНИЯ С АНИМАЦИЕЙ ---
    function nextWeek() {
        animDir = -1 // Двигаемся влево (как бы идем вперед)
        weekAnim.restart() // Запускаем анимацию исчезновения
        // Сама смена даты произойдет в середине анимации (см. ParallelAnimation ниже)
    }

    function prevWeek() {
        animDir = 1 // Двигаемся вправо
        weekAnim.restart()
    }

    function applyDateChange() {
        var d = new Date(selectedDate)
        d.setDate(d.getDate() + (animDir * -7)) // Если dir=-1 (next), то +7 дней
        selectedDate = d
        refreshList()
    }

    Component.onCompleted: refreshList()

    header: Column {
        width: parent.width; spacing: 10; padding: 20; topPadding: 40

        // ЗАГОЛОВОК
        RowLayout {
            width: parent.width
            spacing: 10 // Уменьшил отступ между текстом и кнопкой

            Column {
                // Текст даты
                Text {
                    text: toSqlDate(selectedDate) === toSqlDate(new Date()) ? "Сегодня" : Qt.formatDate(selectedDate, "d MMMM")
                    font.pixelSize: 28; font.bold: true; color: "white"
                }
                Text {
                    text: "Ваши привычки"
                    font.pixelSize: 14; color: appWindow.subTextColor
                }
            }

            // Кнопка Календаря (Теперь всегда рядом)
            Button {
                Layout.alignment: Qt.AlignVCenter
                background: Rectangle {
                    color: appWindow.surfaceColor; radius: 12
                    border.color: appWindow.subTextColor; border.width: 1
                }
                contentItem: Row {
                    spacing: 6; leftPadding: 10; rightPadding: 10
                    Text { text: "📅"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                }
                onClicked: datePickerDialog.open() // Всегда открывает диалог
            }

            // Кнопка "В СЕГОДНЯ" (Появляется только если мы не сегодня)
            Button {
                visible: toSqlDate(selectedDate) !== toSqlDate(new Date())
                Layout.alignment: Qt.AlignVCenter
                background: Rectangle {
                    color: appWindow.accentColor; radius: 12
                }
                contentItem: Text {
                    text: "В сегодня"; color: "white"; font.bold: true; font.pixelSize: 12
                    leftPadding: 10; rightPadding: 10; verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    selectedDate = new Date()
                    refreshList()
                }
            }

            // Распорка в конце
            Item { Layout.fillWidth: true }
        }

        Item { height: 10 }

        // КАЛЕНДАРНАЯ ЛЕНТА С АНИМАЦИЕЙ
        Item {
            id: calendarContainer
            width: parent.width
            height: 80
            clip: true // Важно, чтобы анимация не вылезала за края

            // АНИМАЦИЯ ПЕРЕХОДА
            SequentialAnimation {
                id: weekAnim

                // 1. Исчезновение и сдвиг
                ParallelAnimation {
                    NumberAnimation { target: calendarRow; property: "opacity"; to: 0; duration: 100 }
                    NumberAnimation {
                        target: calendarRow; property: "x";
                        to: animDir === -1 ? -50 : 50; // Сдвигаем в сторону ухода
                        duration: 100
                    }
                }

                // 2. Мгновенная смена данных
                ScriptAction { script: {
                    applyDateChange()
                    calendarRow.x = (animDir === -1 ? 50 : -50) // Телепортируем в противоположную сторону
                }}

                // 3. Появление и возврат в центр
                ParallelAnimation {
                    NumberAnimation { target: calendarRow; property: "opacity"; to: 1; duration: 150 }
                    NumberAnimation { target: calendarRow; property: "x"; to: 0; duration: 150; easing.type: Easing.OutQuad }
                }
            }

            RowLayout {
                id: calendarRow
                anchors.fill: parent
                spacing: 8

                Repeater {
                    model: 7
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        color: isSelected(index) ? appWindow.accentColor : appWindow.surfaceColor
                        radius: 14
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Column {
                            anchors.centerIn: parent; spacing: 4
                            Text {
                                text: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"][index]
                                color: isSelected(index) ? "white" : appWindow.subTextColor
                                font.pixelSize: 11; font.bold: true
                            }
                            Text {
                                text: getDateOfButton(index).getDate()
                                color: "white"; font.bold: true; font.pixelSize: 18
                            }
                            Rectangle {
                                width: 4; height: 4; radius: 2
                                color: isSelected(index) ? "white" : appWindow.accentColor
                                visible: isToday(index)
                            }
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                property real startX: 0

                onPressed: (mouse) => { startX = mouse.x }
                onReleased: (mouse) => {
                    var diff = mouse.x - startX
                    if (Math.abs(diff) > 50) {
                        if (diff < 0) nextWeek()
                        else prevWeek()
                    } else {
                        // Клик
                        var itemWidth = width / 7
                        var index = Math.floor(mouse.x / itemWidth)
                        if (index >= 0 && index < 7) {
                            selectedDate = getDateOfButton(index)
                            refreshList()
                        }
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

            MouseArea {
                anchors.fill: parent; width: parent.width - 60
                onClicked: {
                    stackView.push("AddHabitPage.qml", {
                        habitId: model.habitId, initialName: model.name,
                        initialDesc: model.description, initialFreq: model.frequency
                    })
                    stackView.currentItem.onClosing.connect(refreshList)
                }
            }

            RowLayout {
                id: contentLayout
                anchors.fill: parent; anchors.margins: 15; spacing: 15
                ColumnLayout {
                    Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 4
                    RowLayout {
                        Text {
                            text: model.name
                            font.pixelSize: 16; font.bold: true
                            color: model.done ? "#66FFFFFF" : appWindow.textColor
                            font.strikeout: model.done
                            Layout.fillWidth: true; wrapMode: Text.Wrap
                        }
                        Rectangle {
                            visible: model.frequency === 1
                            color: "#3A3A4C"; radius: 4; width: 70; height: 18
                            Text { anchors.centerIn: parent; text: "Еженедельно"; color: "#AAAAAA"; font.pixelSize: 9 }
                        }
                    }
                    Text {
                        text: model.description; font.pixelSize: 13; color: appWindow.subTextColor
                        visible: text !== ""; Layout.fillWidth: true; wrapMode: Text.WordWrap
                    }
                }
                Rectangle { width: 1; height: 30; color: "#404050"; Layout.alignment: Qt.AlignVCenter }
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
                            dbHandler.checkHabit(model.habitId, toSqlDate(selectedDate), newState)
                            model.done = newState
                        }
                    }
                }
            }
        }
        Text {
            visible: habitModel.count === 0
            text: "Нет задач на этот день"
            color: appWindow.subTextColor
            anchors.centerIn: parent
            font.pixelSize: 16
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

    Dialog {
        id: datePickerDialog
        anchors.centerIn: parent
        width: 280; height: 200
        modal: true
        background: Rectangle { color: appWindow.surfaceColor; radius: 20; border.color: appWindow.accentColor }
        ColumnLayout {
            anchors.centerIn: parent
            Text { text: "Пока только 'Сегодня' :)"; color: "white" }
            Button {
                text: "Закрыть"
                onClicked: datePickerDialog.close()
            }
        }
    }
}
