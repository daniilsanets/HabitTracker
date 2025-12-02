#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle> // <--- 1. Добавляем этот заголовок
#include "databasehandler.h"

int main(int argc, char *argv[])
{
    // 2. Устанавливаем стиль "Basic" ПЕРЕД созданием app.
    // Это разрешает кастомизацию (background, contentItem) для кнопок.
    QQuickStyle::setStyle("Basic");

    QGuiApplication app(argc, argv);

    // Инициализация базы данных
    DatabaseHandler dbHandler;
    dbHandler.connectToDatabase();

    QQmlApplicationEngine engine;

    // Передаем объект базы данных в QML
    engine.rootContext()->setContextProperty("dbHandler", &dbHandler);

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
