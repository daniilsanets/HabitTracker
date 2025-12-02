#include "databasehandler.h"
#include <QStandardPaths>
#include <QDir>
#include <QCoreApplication>

DatabaseHandler::DatabaseHandler(QObject *parent) : QObject(parent) {}

DatabaseHandler::~DatabaseHandler() {
    if (m_db.isOpen()) m_db.close();
}

void DatabaseHandler::connectToDatabase()
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString dbPath = path + "/habittracker_pro.sqlite"; // Новое имя базы для чистого старта

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qDebug() << "Error:" << m_db.lastError();
    } else {
        qDebug() << "Database connected.";
        QSqlQuery query;
        query.exec("CREATE TABLE IF NOT EXISTS habits (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT)");
        query.exec("CREATE TABLE IF NOT EXISTS history (id INTEGER PRIMARY KEY AUTOINCREMENT, habit_id INTEGER, date TEXT, status INTEGER)");
    }
}

bool DatabaseHandler::addHabit(const QString &name, const QString &description) {
    QSqlQuery query;
    query.prepare("INSERT INTO habits (name, description) VALUES (:name, :description)");
    query.bindValue(":name", name);
    query.bindValue(":description", description);
    return query.exec();
}

QList<QString> DatabaseHandler::getHabits() {
    QList<QString> list;
    QSqlQuery query("SELECT id, name, description FROM habits");
    while (query.next()) {
        QString id = query.value(0).toString();
        QString name = query.value(1).toString();
        QString desc = query.value(2).toString();
        list.append(id + ":" + name + ":" + desc);
    }
    return list;
}

void DatabaseHandler::checkHabit(int id, bool checked) {
    QString today = QDate::currentDate().toString(Qt::ISODate);
    QSqlQuery query;
    query.prepare("DELETE FROM history WHERE habit_id = :id AND date = :date");
    query.bindValue(":id", id);
    query.bindValue(":date", today);
    query.exec();

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
    if (query.exec() && query.next()) return query.value(0).toBool();
    return false;
}

void DatabaseHandler::removeHabit(int id) {
    QSqlQuery query;
    query.prepare("DELETE FROM habits WHERE id = :id");
    query.bindValue(":id", id);
    query.exec();

    query.prepare("DELETE FROM history WHERE habit_id = :id");
    query.bindValue(":id", id);
    query.exec();
}

int DatabaseHandler::getTotalCompletions(int id) {
    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM history WHERE habit_id = :id");
    query.bindValue(":id", id);
    if(query.exec() && query.next()) return query.value(0).toInt();
    return 0;
}
