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
    // Используем v3, как договорились ранее
    QString dbPath = path + "/habittracker_v3.sqlite";

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qDebug() << "Error:" << m_db.lastError();
    } else {
        qDebug() << "Database connected.";
        QSqlQuery query;

        query.exec("CREATE TABLE IF NOT EXISTS habits ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                   "name TEXT, "
                   "description TEXT, "
                   "frequency INTEGER DEFAULT 0, "
                   "created_date TEXT)");

        query.exec("CREATE TABLE IF NOT EXISTS history ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                   "habit_id INTEGER, "
                   "date TEXT, "
                   "status INTEGER)");
    }
}

bool DatabaseHandler::addHabit(const QString &name, const QString &description, int frequency) {
    QSqlQuery query;
    // Сохраняем дату создания
    QString today = QDate::currentDate().toString("yyyy-MM-dd");

    query.prepare("INSERT INTO habits (name, description, frequency, created_date) VALUES (:name, :description, :freq, :created)");
    query.bindValue(":name", name);
    query.bindValue(":description", description);
    query.bindValue(":freq", frequency);
    query.bindValue(":created", today);
    return query.exec();
}

bool DatabaseHandler::updateHabit(int id, const QString &name, const QString &description, int frequency) {
    QSqlQuery query;
    query.prepare("UPDATE habits SET name = :name, description = :description, frequency = :freq WHERE id = :id");
    query.bindValue(":name", name);
    query.bindValue(":description", description);
    query.bindValue(":freq", frequency);
    query.bindValue(":id", id);
    return query.exec();
}

QList<QString> DatabaseHandler::getHabits(const QString &viewDate) {
    QList<QString> list;
    QSqlQuery query;

    // ЕСЛИ ДАТА НЕ ПЕРЕДАНА (пустая) -> Загружаем ВСЕ привычки (для статистики)
    if (viewDate.isEmpty()) {
        query.prepare("SELECT id, name, description, frequency, created_date FROM habits");
    }
    // ЕСЛИ ДАТА ЕСТЬ -> Фильтруем (для календаря)
    else {
        query.prepare("SELECT id, name, description, frequency, created_date FROM habits WHERE created_date <= :viewDate OR created_date IS NULL");
        query.bindValue(":viewDate", viewDate);
    }

    if(query.exec()) {
        while (query.next()) {
            QString id = query.value(0).toString();
            QString name = query.value(1).toString();
            QString desc = query.value(2).toString();
            QString freq = query.value(3).toString();
            QString created = query.value(4).toString();

            list.append(id + ":" + name + ":" + desc + ":" + freq + ":" + created);
        }
    }
    return list;
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
    query.prepare("SELECT COUNT(*) FROM history WHERE habit_id = :id AND status = 1");
    query.bindValue(":id", id);
    if(query.exec() && query.next()) return query.value(0).toInt();
    return 0;
}

void DatabaseHandler::checkHabit(int id, const QString &dateString, bool checked) {
    QSqlQuery query;
    query.prepare("DELETE FROM history WHERE habit_id = :id AND date = :date");
    query.bindValue(":id", id);
    query.bindValue(":date", dateString);
    query.exec();

    if (checked) {
        query.prepare("INSERT INTO history (habit_id, date, status) VALUES (:id, :date, 1)");
        query.bindValue(":id", id);
        query.bindValue(":date", dateString);
        query.exec();
    }
}

bool DatabaseHandler::isHabitCompleted(int id, const QString &dateString) {
    QSqlQuery query;
    query.prepare("SELECT status FROM history WHERE habit_id = :id AND date = :date");
    query.bindValue(":id", id);
    query.bindValue(":date", dateString);
    if (query.exec() && query.next()) return query.value(0).toBool();
    return false;
}

int DatabaseHandler::getCurrentStreak(int id) {
    int streak = 0;
    QDate checkDate = QDate::currentDate();
    if (isHabitCompleted(id, checkDate.toString(Qt::ISODate))) streak++;

    while (true) {
        checkDate = checkDate.addDays(-1);
        if (isHabitCompleted(id, checkDate.toString(Qt::ISODate))) {
            streak++;
        } else {
            if (checkDate == QDate::currentDate().addDays(-1) && streak == 0) break;
            if (streak > 0 && !isHabitCompleted(id, QDate::currentDate().toString(Qt::ISODate)) && checkDate == QDate::currentDate().addDays(-1)) break;
            break;
        }
    }
    // Перестраховочный пересчет
    streak = 0;
    checkDate = QDate::currentDate();
    if (isHabitCompleted(id, checkDate.toString(Qt::ISODate))) streak++;
    while(true) {
        checkDate = checkDate.addDays(-1);
        if (isHabitCompleted(id, checkDate.toString(Qt::ISODate))) streak++;
        else break;
    }
    return streak;
}
