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
            width: parent.width * 0.9; height: 100
            radius: 20
            color: appWindow.surfaceColor
            anchors.horizontalCenter: parent.horizontalCenter

            RowLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 20
                Item {
                    Layout.preferredWidth: 60; Layout.preferredHeight: 60
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            var centerX = width / 2; var centerY = height / 2;
                            var radius = width / 2 - 4;
                            ctx.reset();
                            ctx.beginPath(); ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                            ctx.lineWidth = 6; ctx.strokeStyle = "#3A3A4C"; ctx.stroke();

                            var percent = Math.min(model.count, 30) / 30;
                            var endAngle = (percent * 2 * Math.PI) - (Math.PI / 2);
                            ctx.beginPath(); ctx.arc(centerX, centerY, radius, -Math.PI / 2, endAngle);
                            ctx.lineWidth = 6; ctx.strokeStyle = appWindow.accentColor; ctx.lineCap = "round"; ctx.stroke();
                        }
                    }
                    Text { anchors.centerIn: parent; text: model.count; color: "white"; font.bold: true; font.pixelSize: 16 }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Text { text: model.name; color: "white"; font.bold: true; font.pixelSize: 18 }
                    RowLayout {
                        spacing: 5
                        Text {
                            text: "🔥 " + model.streak + " дн. подряд"
                            color: model.streak > 0 ? "#FFAA00" : appWindow.subTextColor
                            font.bold: true; font.pixelSize: 14
                        }
                    }
                    Text { text: "Всего выполнено: " + model.count; color: appWindow.subTextColor; font.pixelSize: 12 }
                }
            }
        }
    }

    // ЛОГИКА ЗАГРУЗКИ
    function refreshStats() {
        statsModel.clear()
        // Вызываем БЕЗ аргументов (благодаря правке в C++, это вернет все привычки)
        var list = dbHandler.getHabits("")

        for(var i=0; i<list.length; i++) {
            var parts = list[i].split(":")
            var id = parseInt(parts[0])
            var name = parts[1]
            var count = dbHandler.getTotalCompletions(id)
            var streak = dbHandler.getCurrentStreak(id)
            statsModel.append({"name": name, "count": count, "streak": streak})
        }
    }

    Component.onCompleted: refreshStats()
}
