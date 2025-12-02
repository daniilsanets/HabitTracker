#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "databasehandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Инициализация базы данных
    DatabaseHandler dbHandler;
    dbHandler.connectToDatabase();

    QQmlApplicationEngine engine;

    // Передаем объект базы данных в QML
    engine.rootContext()->setContextProperty("dbHandler", &dbHandler);

    const QUrl url(QStringLiteral("qrc:/main.qml")); // Проверьте путь, если используете Qt6, может быть просто "qrc:/main.qml"

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
