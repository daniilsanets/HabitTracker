import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: addPage
    background: Rectangle { color: appWindow.bgColor }

    header: Item {
        height: 60

        // Кнопка Назад
        Item {
            width: 80
            height: parent.height
            anchors.left: parent.left
            MouseArea { anchors.fill: parent; onClicked: stackView.pop() }

            RowLayout {
                anchors.centerIn: parent
                spacing: 5
                Text {
                    text: "‹"
                    color: appWindow.accentColor
                    font.pixelSize: 36
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }
                Text {
                    text: "Назад"
                    color: appWindow.accentColor
                    font.pixelSize: 16
                    font.bold: true
                }
            }
        }

        Text {
            text: "Новая привычка"
            color: "white"
            font.bold: true
            font.pixelSize: 18
            anchors.centerIn: parent
        }
    }

    // ScrollView нужен для клавиатуры, но мы скрываем полосу
    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth // Запрет горизонтального скролла

        // !!! ГЛАВНОЕ ИЗМЕНЕНИЕ: Скрываем визуальную полосу прокрутки !!!
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: parent.width
            spacing: 25
            anchors.margins: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Item { height: 20 }

            Text {
                text: "Что будем трекать?"
                color: "white"
                font.pixelSize: 26
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            // Поле Названия
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                Label {
                    text: "НАЗВАНИЕ"
                    color: appWindow.subTextColor
                    font.pixelSize: 12
                    font.bold: true
                    Layout.leftMargin: 5
                }
                TextField {
                    id: nameField
                    placeholderText: "Например: Бег"
                    placeholderTextColor: "#606070"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    color: "white"
                    font.pixelSize: 16
                    leftPadding: 15
                    background: Rectangle {
                        color: appWindow.surfaceColor
                        radius: 12
                        border.color: nameField.activeFocus ? appWindow.accentColor : "transparent"
                        border.width: 2
                    }
                }
            }

            // Поле Описания
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                Label {
                    text: "ОПИСАНИЕ"
                    color: appWindow.subTextColor
                    font.pixelSize: 12
                    font.bold: true
                    Layout.leftMargin: 5
                }
                TextField {
                    id: descField
                    placeholderText: "Детали..."
                    placeholderTextColor: "#606070"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    color: "white"
                    font.pixelSize: 16
                    leftPadding: 15
                    background: Rectangle {
                        color: appWindow.surfaceColor
                        radius: 12
                        border.color: descField.activeFocus ? appWindow.accentColor : "transparent"
                        border.width: 2
                    }
                }
            }

            Item { height: 20 }

            // Кнопка Сохранить
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 55
                Layout.margins: 10

                background: Rectangle {
                    color: nameField.text.length > 0 ? appWindow.accentColor : "#3A3A4C"
                    radius: 16
                }

                contentItem: Text {
                    text: "Сохранить привычку"
                    color: nameField.text.length > 0 ? "white" : "#808090"
                    font.bold: true
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                enabled: nameField.text.length > 0
                onClicked: {
                    dbHandler.addHabit(nameField.text, descField.text)
                    stackView.pop()
                    if (stackView.currentItem && stackView.currentItem.refreshList) {
                        stackView.currentItem.refreshList()
                    }
                }
            }
        }
    }
}
