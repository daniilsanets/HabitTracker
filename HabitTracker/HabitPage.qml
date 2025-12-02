import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page
    title: "Мои привычки"

    // Функция обновления списка (вызывается при открытии страницы)
    function refreshList() {
        habitModel.clear()
        var list = dbHandler.getHabits()
        for (var i = 0; i < list.length; i++) {
            var parts = list[i].split(":")
            var id = parseInt(parts[0])
            var name = parts[1]
            var isDone = dbHandler.isHabitCompletedToday(id)
            habitModel.append({ "habitId": id, "name": name, "done": isDone })
        }
    }

    Component.onCompleted: refreshList()

    header: ToolBar {
        Label {
            text: page.title
            anchors.centerIn: parent
            font.pixelSize: 20
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: ListModel { id: habitModel }

            delegate: ItemDelegate {
                width: parent.width

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    CheckBox {
                        checked: model.done
                        onCheckedChanged: {
                            dbHandler.checkHabit(model.habitId, checked)
                        }
                    }

                    Text {
                        text: model.name
                        font.pixelSize: 16
                        Layout.fillWidth: true
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10

            Button {
                text: "Добавить"
                onClicked: {
                    stackView.push("AddHabitPage.qml")
                    // Обновим список при возврате
                    stackView.currentItem.onClosing.connect(refreshList)
                }
            }
            Button {
                text: "О программе"
                onClicked: stackView.push("AboutPage.qml")
            }
        }
    }
}
