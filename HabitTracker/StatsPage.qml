import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    background: Rectangle { color: appWindow.bgColor }

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
            text: "Ваш прогресс"
            color: "white"; font.bold: true; font.pixelSize: 18; anchors.centerIn: parent
        }
    }

    ListView {
        anchors.fill: parent; anchors.topMargin: 20
        model: ListModel { id: statsModel }
        spacing: 15; clip: true

        delegate: Rectangle {
            width: parent.width * 0.9; height: 100 // Увеличили высоту
            radius: 20
            color: appWindow.surfaceColor
            anchors.horizontalCenter: parent.horizontalCenter

            RowLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 20

                // Левая часть: Круговой индикатор прогресса (Canvas)
                Item {
                    Layout.preferredWidth: 60; Layout.preferredHeight: 60

                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            var centerX = width / 2;
                            var centerY = height / 2;
                            var radius = width / 2 - 4; // Отступ для толщины

                            ctx.reset();

                            // Серый круг (фон)
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                            ctx.lineWidth = 6;
                            ctx.strokeStyle = "#3A3A4C";
                            ctx.stroke();

                            // Цветной круг (прогресс)
                            // Примерная логика: (total completions % 30) / 30 * 2PI (для визуализации месячной цели)
                            // Или просто: макс 30 дней
                            var percent = Math.min(model.count, 30) / 30;
                            var endAngle = (percent * 2 * Math.PI) - (Math.PI / 2); // -90 deg start

                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, -Math.PI / 2, endAngle);
                            ctx.lineWidth = 6;
                            ctx.strokeStyle = appWindow.accentColor;
                            ctx.lineCap = "round";
                            ctx.stroke();
                        }
                    }
                    // Число внутри круга
                    Text {
                        anchors.centerIn: parent
                        text: model.count
                        color: "white"; font.bold: true; font.pixelSize: 16
                    }
                }

                // Правая часть: Текст и Стрик
                ColumnLayout {
                    Layout.fillWidth: true
                    Text {
                        text: model.name; color: "white"; font.bold: true; font.pixelSize: 18
                    }

                    // Блок СТРИКА (Огонек)
                    RowLayout {
                        spacing: 5
                        Text {
                            text: "🔥 " + model.streak + " дн. подряд"
                            // Если стрик > 0, цвет оранжевый, иначе серый
                            color: model.streak > 0 ? "#FFAA00" : appWindow.subTextColor
                            font.bold: true; font.pixelSize: 14
                        }
                    }

                    Text {
                         text: "Всего выполнено раз: " + model.count
                         color: appWindow.subTextColor; font.pixelSize: 12
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
            var streak = dbHandler.getCurrentStreak(id) // Получаем стрик
            statsModel.append({"name": name, "count": count, "streak": streak})
        }
    }
}
