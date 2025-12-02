import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: addPage
    background: Rectangle { color: appWindow.bgColor }

    // --- Свойства для РЕДАКТИРОВАНИЯ ---
    property int habitId: -1
    property string initialName: ""
    property string initialDesc: ""
    property int initialFreq: 0 // 0 - Ежедневно, 1 - Еженедельно

    // Локальное свойство для хранения выбранной частоты (вместо ComboBox)
    property int selectedFreqIndex: initialFreq

    Component.onCompleted: {
        if (habitId !== -1) {
            nameField.text = initialName
            descField.text = initialDesc
            selectedFreqIndex = initialFreq
        }
    }

    // --- НОВЫЙ ХЕДЕР ---
    header: Item {
        height: 80

        // Кнопка Закрыть (вместо Назад)
        Rectangle {
            width: 40; height: 40; radius: 14
            color: appWindow.surfaceColor
            anchors.left: parent.left; anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter

            Text { text: "✕"; color: "white"; font.pixelSize: 18; anchors.centerIn: parent }
            MouseArea { anchors.fill: parent; onClicked: stackView.pop() }
        }

        // Заголовок
        Text {
            text: habitId === -1 ? "Новая привычка" : "Редактирование"
            color: "white"
            font.bold: true; font.pixelSize: 20
            anchors.centerIn: parent
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.topMargin: 10
        clip: true
        contentWidth: availableWidth
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: parent.width - 40 // Отступы по 20px с краев
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 25

            // --- 1. НАЗВАНИЕ ---
            ColumnLayout {
                spacing: 10; Layout.fillWidth: true
                Text { text: "Название"; color: appWindow.subTextColor; font.bold: true; font.pixelSize: 14 }

                TextField {
                    id: nameField
                    Layout.fillWidth: true; Layout.preferredHeight: 60
                    placeholderText: "Например: Бег по утрам"
                    placeholderTextColor: "#606070"
                    color: "white"; font.pixelSize: 18
                    leftPadding: 20; rightPadding: 20

                    background: Rectangle {
                        color: appWindow.surfaceColor
                        radius: 18
                        border.width: nameField.activeFocus ? 2 : 0
                        border.color: appWindow.accentColor
                        // Иконка карандаша справа
                        Text { text: "✏️"; anchors.right: parent.right; anchors.rightMargin: 15; anchors.verticalCenter: parent.verticalCenter; opacity: 0.5; font.pixelSize: 16 }
                    }
                }
            }

            // --- 2. ОПИСАНИЕ ---
            ColumnLayout {
                spacing: 10; Layout.fillWidth: true
                Text { text: "Описание (опционально)"; color: appWindow.subTextColor; font.bold: true; font.pixelSize: 14 }

                TextField {
                    id: descField
                    Layout.fillWidth: true; Layout.preferredHeight: 60
                    placeholderText: "Ради чего вы это делаете?"
                    placeholderTextColor: "#606070"
                    color: "white"; font.pixelSize: 16
                    leftPadding: 20; rightPadding: 20

                    background: Rectangle {
                        color: appWindow.surfaceColor
                        radius: 18
                        border.width: descField.activeFocus ? 2 : 0
                        border.color: appWindow.accentColor
                    }
                }
            }

            // --- 3. ВЫБОР ЧАСТОТЫ (КАРТОЧКИ) ---
            ColumnLayout {
                spacing: 15; Layout.fillWidth: true
                Text { text: "Как часто?"; color: appWindow.subTextColor; font.bold: true; font.pixelSize: 14 }

                RowLayout {
                    spacing: 15; Layout.fillWidth: true

                    // Карточка: Каждый день
                    Rectangle {
                        Layout.fillWidth: true; height: 110
                        radius: 20
                        color: selectedFreqIndex === 0 ? appWindow.accentColor : appWindow.surfaceColor
                        Behavior on color { ColorAnimation { duration: 200 } }

                        Column {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: "🔥"; font.pixelSize: 28 }
                            Text { text: "Каждый день"; color: "white"; font.bold: true; font.pixelSize: 14 }
                        }
                        MouseArea { anchors.fill: parent; onClicked: selectedFreqIndex = 0 }

                        // Галочка выбора
                        Rectangle {
                            width: 24; height: 24; radius: 12
                            color: "white"; visible: selectedFreqIndex === 0
                            anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 10
                            Text { text: "✓"; color: appWindow.accentColor; anchors.centerIn: parent; font.bold: true }
                        }
                    }

                    // Карточка: Раз в неделю
                    Rectangle {
                        Layout.fillWidth: true; height: 110
                        radius: 20
                        color: selectedFreqIndex === 1 ? appWindow.accentColor : appWindow.surfaceColor
                        Behavior on color { ColorAnimation { duration: 200 } }

                        Column {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: "📅"; font.pixelSize: 28 }
                            Text { text: "Раз в неделю"; color: "white"; font.bold: true; font.pixelSize: 14 }
                        }
                        MouseArea { anchors.fill: parent; onClicked: selectedFreqIndex = 1 }

                        Rectangle {
                            width: 24; height: 24; radius: 12
                            color: "white"; visible: selectedFreqIndex === 1
                            anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 10
                            Text { text: "✓"; color: appWindow.accentColor; anchors.centerIn: parent; font.bold: true }
                        }
                    }
                }
            }

            Item { height: 20 }

            // --- 4. КНОПКА СОХРАНЕНИЯ ---
            Button {
                Layout.fillWidth: true; Layout.preferredHeight: 60
                background: Rectangle {
                    color: nameField.text.length > 0 ? appWindow.accentColor : "#3A3A4C"
                    radius: 20
                }

                // Используем Item как контейнер, чтобы anchors работали идеально
                contentItem: Item {
                    anchors.fill: parent

                    Row {
                        spacing: 10
                        anchors.centerIn: parent // Центрируем Row внутри Item

                        Text {
                            text: habitId === -1 ? "✨" : "💾"
                            font.pixelSize: 20
                            // Важно: выравнивание по вертикали, чтобы иконка и текст были на одной линии
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: habitId === -1 ? "Создать привычку" : "Сохранить изменения"
                            color: nameField.text.length > 0 ? "white" : "#808090"
                            font.bold: true; font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                enabled: nameField.text.length > 0
                onClicked: {
                    if (habitId === -1) {
                        dbHandler.addHabit(nameField.text, descField.text, selectedFreqIndex)
                    } else {
                        dbHandler.updateHabit(habitId, nameField.text, descField.text, selectedFreqIndex)
                    }
                    stackView.pop()
                    if (stackView.currentItem && stackView.currentItem.refreshList) {
                        stackView.currentItem.refreshList()
                    }
                }
            }

            // --- 5. УДАЛЕНИЕ (только при редактировании) ---
            Button {
                visible: habitId !== -1
                Layout.fillWidth: true; Layout.preferredHeight: 50
                background: Rectangle { color: "transparent" }
                contentItem: Text {
                    text: "Удалить эту привычку"
                    color: appWindow.dangerColor
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    dbHandler.removeHabit(habitId)
                    stackView.pop()
                    if (stackView.currentItem && stackView.currentItem.refreshList) {
                        stackView.currentItem.refreshList()
                    }
                }
            }

            Item { height: 40 } // Отступ снизу
        }
    }
}
