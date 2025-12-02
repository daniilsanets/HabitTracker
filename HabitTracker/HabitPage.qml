import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page
    background: Rectangle { color: appWindow.bgColor }

    property date selectedDate: new Date()

    // Вспомогательная дата для выбора в календаре (какой месяц смотрим)
    property date pickerDate: new Date()

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

    // Вспомогательные функции для Календаря-Пикера
    function getDaysInMonth(d) {
        return new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate();
    }

    function getFirstDayOffset(d) {
        // 0 - Пн, 6 - Вс для нашей сетки
        var f = new Date(d.getFullYear(), d.getMonth(), 1).getDay();
        return f === 0 ? 6 : f - 1;
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

    // --- ЛОГИКА НЕДЕЛЬНОЙ ЛЕНТЫ ---
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

    // Функции смены недели (вызываются анимацией)
    function shiftDate(weeks) {
        var d = new Date(selectedDate)
        d.setDate(d.getDate() + (weeks * 7))
        selectedDate = d
        refreshList()
    }

    Component.onCompleted: refreshList()

    header: Column {
        width: parent.width; spacing: 10; padding: 20; topPadding: 40

        // ЗАГОЛОВОК
        RowLayout {
            width: parent.width
            spacing: 10
            Column {
                Text {
                    text: toSqlDate(selectedDate) === toSqlDate(new Date()) ? "Сегодня" : Qt.formatDate(selectedDate, "d MMMM")
                    font.pixelSize: 28; font.bold: true; color: "white"
                }
                Text {
                    text: "Ваши привычки"
                    font.pixelSize: 14; color: appWindow.subTextColor
                }
            }

            // КНОПКА КАЛЕНДАРЯ
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
                onClicked: {
                    // При открытии устанавливаем дату пикера на выбранную дату
                    pickerDate = new Date(selectedDate)
                    datePickerDialog.open()
                }
            }

            Button {
                visible: toSqlDate(selectedDate) !== toSqlDate(new Date())
                Layout.alignment: Qt.AlignVCenter
                background: Rectangle { color: appWindow.accentColor; radius: 12 }
                contentItem: Text {
                    text: "В сегодня"; color: "white"; font.bold: true; font.pixelSize: 12
                    leftPadding: 10; rightPadding: 10; verticalAlignment: Text.AlignVCenter
                }
                onClicked: { selectedDate = new Date(); refreshList() }
            }
            Item { Layout.fillWidth: true }
        }

        Item { height: 10 }

        // --- ЛЕНТА ДНЕЙ С ЖИВЫМ СВАЙПОМ ---
        Item {
            id: calendarContainer
            width: parent.width
            height: 80
            clip: true

            RowLayout {
                id: calendarRow
                width: parent.width
                spacing: 8

                // Важно: якоря должны быть сброшены, чтобы мы могли менять x вручную
                // Используем x: 0 по умолчанию

                Repeater {
                    model: 7
                    delegate: Rectangle {
                        // Растягиваем элементы, чтобы они заполнили ширину контейнера
                        Layout.preferredWidth: (calendarContainer.width - (8 * 6)) / 7
                        Layout.preferredHeight: 70
                        color: isSelected(index) ? appWindow.accentColor : appWindow.surfaceColor
                        radius: 14

                        // Анимация цвета при клике
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

            // МУЛЬТИ-СВАЙП MOUSE AREA
            MouseArea {
                anchors.fill: parent
                property real startX: 0
                property bool isDragging: false

                onPressed: (mouse) => {
                    startX = mouse.x
                    isDragging = false
                    // Останавливаем анимации, если они идут
                    finishSwipeAnim.stop()
                    bounceBackAnim.stop()
                }

                onPositionChanged: (mouse) => {
                    var diff = mouse.x - startX
                    // Начинаем двигать ряд вслед за пальцем
                    calendarRow.x = diff
                    if (Math.abs(diff) > 10) isDragging = true
                }

                onReleased: (mouse) => {
                    // Если сдвинули достаточно далеко - меняем неделю
                    if (calendarRow.x < -100) {
                        // Свайп влево (след. неделя)
                        finishSwipeAnim.toX = -calendarContainer.width
                        finishSwipeAnim.direction = 1 // Next
                        finishSwipeAnim.start()
                    } else if (calendarRow.x > 100) {
                        // Свайп вправо (пред. неделя)
                        finishSwipeAnim.toX = calendarContainer.width
                        finishSwipeAnim.direction = -1 // Prev
                        finishSwipeAnim.start()
                    } else {
                        // Если сдвинули мало - возвращаем на место
                        if (isDragging) bounceBackAnim.start()
                        else {
                            // Это был клик
                            var itemWidth = width / 7
                            var index = Math.floor(mouse.x / itemWidth)
                            if (index >= 0 && index < 7) {
                                selectedDate = getDateOfButton(index)
                                refreshList()
                            }
                            bounceBackAnim.start() // На всякий случай выравниваем
                        }
                    }
                }
            }
        }
    }

    // Анимация завершения свайпа (улетает за край -> меняет дату -> прилетает с другой стороны)
    SequentialAnimation {
        id: finishSwipeAnim
        property int direction: 0 // 1 = Next, -1 = Prev
        property int toX: 0

        // 1. Долетаем до края
        NumberAnimation { target: calendarRow; property: "x"; to: finishSwipeAnim.toX; duration: 200; easing.type: Easing.OutQuad }

        // 2. Мгновенно меняем дату и телепортируемся на противоположный край
        ScriptAction {
            script: {
                shiftDate(finishSwipeAnim.direction)
                // Если ушли влево, появляемся справа
                calendarRow.x = (finishSwipeAnim.direction === 1) ? calendarContainer.width : -calendarContainer.width
            }
        }

        // 3. Плавно возвращаемся в центр
        NumberAnimation { target: calendarRow; property: "x"; to: 0; duration: 250; easing.type: Easing.OutBack }
    }

    // Анимация возврата (если передумали свайпать)
    NumberAnimation {
        id: bounceBackAnim
        target: calendarRow
        property: "x"
        to: 0
        duration: 300
        easing.type: Easing.OutBack
    }

    ListView {
        id: listView
        anchors.fill: parent; clip: true; spacing: 12; topMargin: 10; bottomMargin: 100
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
                            text: model.name; font.pixelSize: 16; font.bold: true
                            color: model.done ? "#66FFFFFF" : appWindow.textColor
                            font.strikeout: model.done; Layout.fillWidth: true; wrapMode: Text.Wrap
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

    // --- ПОЛНОЦЕННЫЙ КАЛЕНДАРЬ ---
    Dialog {
        id: datePickerDialog
        anchors.centerIn: parent
        width: 340
        height: 420
        modal: true
        closePolicy: Popup.CloseOnPressOutside
        background: Rectangle { color: appWindow.bgColor; radius: 20; border.color: appWindow.surfaceColor; border.width: 2 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20

            // Шапка календаря (Месяц Год и стрелки)
            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "‹"
                    background: null
                    contentItem: Text { text: "‹"; color: appWindow.accentColor; font.pixelSize: 24; horizontalAlignment: Text.AlignHCenter }
                    onClicked: pickerDate = new Date(pickerDate.getFullYear(), pickerDate.getMonth() - 1, 1)
                }
                Text {
                    text: Qt.formatDate(pickerDate, "MMMM yyyy")
                    color: "white"
                    font.bold: true
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
                Button {
                    text: "›"
                    background: null
                    contentItem: Text { text: "›"; color: appWindow.accentColor; font.pixelSize: 24; horizontalAlignment: Text.AlignHCenter }
                    onClicked: pickerDate = new Date(pickerDate.getFullYear(), pickerDate.getMonth() + 1, 1)
                }
            }

            // Дни недели
            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
                    Text {
                        text: modelData
                        color: appWindow.subTextColor
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Сетка дней
            GridLayout {
                columns: 7
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Пустые ячейки (отступ)
                Repeater {
                    model: getFirstDayOffset(pickerDate)
                    Item { Layout.fillWidth: true; Layout.fillHeight: true }
                }

                // Дни месяца
                Repeater {
                    model: getDaysInMonth(pickerDate)

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: 40
                        radius: 20

                        // Проверяем, является ли этот день выбранным
                        property var currentDay: new Date(pickerDate.getFullYear(), pickerDate.getMonth(), index + 1)
                        property bool isSelected: toSqlDate(currentDay) === toSqlDate(selectedDate)

                        color: isSelected ? appWindow.accentColor : "transparent"
                        border.color: isSelected ? "transparent" : appWindow.surfaceColor
                        border.width: isSelected ? 0 : 1

                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            color: parent.isSelected ? "white" : appWindow.textColor
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                selectedDate = parent.currentDay
                                refreshList()
                                datePickerDialog.close()
                            }
                        }
                    }
                }
            }

            Button {
                text: "Закрыть"
                Layout.alignment: Qt.AlignHCenter
                background: Rectangle { color: appWindow.surfaceColor; radius: 10 }
                contentItem: Text { text: "Отмена"; color: "white"; anchors.centerIn: parent }
                onClicked: datePickerDialog.close()
            }
        }
    }
}
