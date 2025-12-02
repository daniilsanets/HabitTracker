#include "databasehandler.h"
#include <QStandardPaths>
#include <QDir>
#include <QCoreApplication>

DatabaseHandler::DatabaseHandler(QObject *parent) : QObject(parent) {}

DatabaseHandler::~DatabaseHandler() {
    if (m_db.isOpen()) {
        m_db.close();
    }
}

void DatabaseHandler::connectToDatabase()
{
    // Определяем путь к базе данных (в папке документов пользователя)
    QString path = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString dbPath = path + "/habittracker.sqlite";

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qDebug() << "Error: connection with database failed" << m_db.lastError();
    } else {
        qDebug() << "Database: connection ok. Path:" << dbPath;

        QSqlQuery query;
        // Таблица привычек
        query.exec("CREATE TABLE IF NOT EXISTS habits ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                   "name TEXT, "
                   "description TEXT)");

        // Таблица истории выполнения
        query.exec("CREATE TABLE IF NOT EXISTS history ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                   "habit_id INTEGER, "
                   "date TEXT, "
                   "status INTEGER)");
    }
}

bool DatabaseHandler::addHabit(const QString &name, const QString &description) {
    QSqlQuery query;
    query.prepare("INSERT INTO habits (name, description) VALUES (:name, :description)");
    query.bindValue(":name", name);
    query.bindValue(":description", description);

    if(query.exec()) {
        return true;
    } else {
        qDebug() << "Add habit error:" << query.lastError();
        return false;
    }
}

QList<QString> DatabaseHandler::getHabits() {
    QList<QString> list;
    QSqlQuery query("SELECT id, name FROM habits");
    while (query.next()) {
        QString id = query.value(0).toString();
        QString name = query.value(1).toString();
        // Формат строки: "ID:Имя" (чтобы потом в QML разделить)
        list.append(id + ":" + name);
    }
    return list;
}

void DatabaseHandler::checkHabit(int id, bool checked) {
    QString today = QDate::currentDate().toString(Qt::ISODate);
    QSqlQuery query;

    // Сначала удаляем старую запись за сегодня, если есть
    query.prepare("DELETE FROM history WHERE habit_id = :id AND date = :date");
    query.bindValue(":id", id);
    query.bindValue(":date", today);
    query.exec();

    // Если галочка стоит - добавляем запись
    if (checked) {
        query.prepare("INSERT INTO history (habit_id, date, status) VALUES (:id, :date, 1)");
        query.bindValue(":id", id);
        query.bindValue(":date", today);
        query.exec();
    }
}

bool DatabaseHandler::isHabitCompletedToday(int id) {
    QString today = QDate::currentDate().toString(Qt::ISODate);
    QSqlQuery query;
    query.prepare("SELECT status FROM history WHERE habit_id = :id AND date = :date");
    query.bindValue(":id", id);
    query.bindValue(":date", today);
    if (query.exec() && query.next()) {
        return query.value(0).toBool();
    }
    return false;
}
