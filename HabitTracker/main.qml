import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: appWindow
    width: 400
    height: 720
    visible: true
    title: qsTr("Habit Tracker")
    color: "#1E1E2E" // Глубокий темный фон

    // --- Глобальная палитра ---
    property color bgColor: "#1E1E2E"
    property color surfaceColor: "#27273A"
    property color accentColor: "#7F5AF0"
    property color textColor: "#FFFFFE"
    property color subTextColor: "#94A1B2"
    property color dangerColor: "#FF4545"

    // --- ЛОГИКА КНОПКИ НАЗАД (ЖЕСТОВ) ---
    property int backPressCount: 0

    // Таймер для сброса счетчика нажатий через 2 секунды
    Timer {
        id: resetBackPress
        interval: 2000
        onTriggered: appWindow.backPressCount = 0
    }

    // Уведомление (Toast) при попытке выхода
    ToolTip {
        id: exitToast
        visible: false
        timeout: 2000
        text: "Нажмите еще раз для выхода"
        x: (parent.width - width) / 2
        y: parent.height - height - 80 // Отступ снизу

        contentItem: Text {
            text: exitToast.text
            color: "white"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
        }
        background: Rectangle {
            color: appWindow.surfaceColor
            radius: 20
            border.color: appWindow.accentColor
            border.width: 1
            opacity: 0.9
        }
    }

    // Перехват системного события "Закрыть" (которое вызывает жест Назад на Android)
    onClosing: (close) => {
        // 1. Если мы не на главной странице (глубина стека > 1), то просто возвращаемся назад
        if (stackView.depth > 1) {
            close.accepted = false // Отменяем закрытие приложения
            stackView.pop()        // Уходим на предыдущую страницу
            return
        }

        // 2. Если мы на главной странице
        if (backPressCount === 0) {
            close.accepted = false // Отменяем закрытие
            backPressCount++       // Увеличиваем счетчик
            resetBackPress.start() // Запускаем таймер сброса
            exitToast.visible = true // Показываем подсказку
        } else {
            // Если нажали второй раз подряд — разрешаем закрытие (accepted = true по умолчанию)
            console.log("App closing...")
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "HabitPage.qml"
        focus: true // Важно для перехвата клавиш, если используются Keys

        // Анимация переходов между окнами
        pushEnter: Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            PropertyAnimation { property: "x"; from: stackView.width; to: 0; duration: 200; easing.type: Easing.OutCubic }
        }
        pushExit: Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
            PropertyAnimation { property: "x"; from: 0; to: -stackView.width * 0.3; duration: 200 }
        }
        popEnter: Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            PropertyAnimation { property: "x"; from: -stackView.width * 0.3; to: 0; duration: 200; easing.type: Easing.OutCubic }
        }
        popExit: Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
            PropertyAnimation { property: "x"; from: 0; to: stackView.width; duration: 200 }
        }
    }
}
