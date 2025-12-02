import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    background: Rectangle { color: appWindow.bgColor }

    header: Item {
        height: 60
        Text {
            text: "< Назад"
            color: appWindow.accentColor
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 20
            MouseArea { anchors.fill: parent; onClicked: stackView.pop() }
        }
        Text {
            text: "Ваш прогресс"
            color: "white"
            font.bold: true
            font.pixelSize: 18
            anchors.centerIn: parent
        }
    }

    ListView {
        anchors.fill: parent
        anchors.topMargin: 20
        model: ListModel { id: statsModel }
        spacing: 15

        delegate: Rectangle {
            width: parent.width * 0.9
            height: 80
            radius: 15
            color: appWindow.surfaceColor
            anchors.horizontalCenter: parent.horizontalCenter

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: model.name
                        color: "white"
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    Text {
                        text: model.count + " раз(а)"
                        color: appWindow.accentColor
                        font.bold: true
                    }
                }

                // Прогресс бар (визуальный, макс 30 дней для примера)
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    color: "#151520" // Темный фон полосы
                    radius: 4

                    Rectangle {
                        width: parent.width * (Math.min(model.count, 30) / 30)
                        height: parent.height
                        radius: 4
                        color: appWindow.accentColor
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        var list = dbHandler.getHabits()
        for(var i=0; i<list.length; i++) {
            var parts = list[i].split(":")
            var id = parseInt(parts[0])
            var name = parts[1]
            var count = dbHandler.getTotalCompletions(id)
            statsModel.append({"name": name, "count": count})
        }
    }
}
