import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: appWindow
    width: 400
    height: 720
    visible: true
    title: qsTr("Habit Tracker")
    color: "#1E1E2E" // Глубокий темный фон

    // --- Глобальная палитра (свойства доступны везде) ---
    property color bgColor: "#1E1E2E"
    property color surfaceColor: "#27273A" // Цвет карточек
    property color accentColor: "#7F5AF0"  // Яркий фиолетовый
    property color textColor: "#FFFFFE"
    property color subTextColor: "#94A1B2"
    property color dangerColor: "#FF4545"

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "HabitPage.qml"

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
