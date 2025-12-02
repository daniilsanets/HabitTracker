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
    // ВАЖНО: Новое имя файла, чтобы создалась новая таблица с колонкой frequency
    QString dbPath = path + "/habittracker_v2.sqlite";

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qDebug() << "Error:" << m_db.lastError();
    } else {
        qDebug() << "Database connected.";
        QSqlQuery query;
        // Добавили поле frequency
        query.exec("CREATE TABLE IF NOT EXISTS habits ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                   "name TEXT, "
                   "description TEXT, "
                   "frequency INTEGER DEFAULT 0)");

        query.exec("CREATE TABLE IF NOT EXISTS history ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                   "habit_id INTEGER, "
                   "date TEXT, "
                   "status INTEGER)");
    }
}

bool DatabaseHandler::addHabit(const QString &name, const QString &description, int frequency) {
    QSqlQuery query;
    query.prepare("INSERT INTO habits (name, description, frequency) VALUES (:name, :description, :freq)");
    query.bindValue(":name", name);
    query.bindValue(":description", description);
    query.bindValue(":freq", frequency);
    return query.exec();
}

// НОВОЕ: Логика редактирования
bool DatabaseHandler::updateHabit(int id, const QString &name, const QString &description, int frequency) {
    QSqlQuery query;
    query.prepare("UPDATE habits SET name = :name, description = :description, frequency = :freq WHERE id = :id");
    query.bindValue(":name", name);
    query.bindValue(":description", description);
    query.bindValue(":freq", frequency);
    query.bindValue(":id", id);
    return query.exec();
}

QList<QString> DatabaseHandler::getHabits() {
    QList<QString> list;
    // Забираем еще и частоту (column 3)
    QSqlQuery query("SELECT id, name, description, frequency FROM habits");
    while (query.next()) {
        QString id = query.value(0).toString();
        QString name = query.value(1).toString();
        QString desc = query.value(2).toString();
        QString freq = query.value(3).toString();
        // Формат: ID : Имя : Описание : Частота
        list.append(id + ":" + name + ":" + desc + ":" + freq);
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
    query.prepare("SELECT COUNT(*) FROM history WHERE habit_id = :id");
    query.bindValue(":id", id);
    if(query.exec() && query.next()) return query.value(0).toInt();
    return 0;
}

void DatabaseHandler::checkHabit(int id, const QString &dateString, bool checked) {
    // dateString должен быть в формате "yyyy-MM-dd"
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

    // Проверяем сначала сегодня. Если сегодня не выполнено, проверим вчера.
    // Если сегодня не выполнено, стрик не прерывается, пока не кончится день.
    if (isHabitCompleted(id, checkDate.toString(Qt::ISODate))) {
        streak++;
    }

    // Идем назад в прошлое
    while (true) {
        checkDate = checkDate.addDays(-1);
        if (isHabitCompleted(id, checkDate.toString(Qt::ISODate))) {
            streak++;
        } else {
            // Если сегодня еще не отмечено, а вчера было - стрик жив.
            // Но если мы уже нашли пропуск ВЧЕРА (или позавчера), то все, серия прервана.
            if (checkDate == QDate::currentDate().addDays(-1) && streak == 0) {
                // Особый случай: вчера не сделано, сегодня не сделано -> стрик 0
                break;
            }
            if (streak > 0 && !isHabitCompleted(id, QDate::currentDate().toString(Qt::ISODate)) && checkDate == QDate::currentDate().addDays(-1)) {
                // Вчера сделано не было, но сегодня мы просто еще не успели.
                // Этот блок сложной логики можно упростить: стрик это подряд идущие дни.
                // Если вчера пропуск - стрик прерван.
                break;
            }
            break;
        }
    }

    // Упрощенная логика для надежности: просто считаем подряд идущие записи history, отсортированные по дате DESC
    // Но так как у нас SQL, сделаем простой перебор дат назад:
    streak = 0;
    checkDate = QDate::currentDate();

    // 1. Проверяем сегодня
    if (isHabitCompleted(id, checkDate.toString(Qt::ISODate))) {
        streak++;
    }

    // 2. Проверяем вчера и дальше
    while(true) {
        checkDate = checkDate.addDays(-1);
        if (isHabitCompleted(id, checkDate.toString(Qt::ISODate))) {
            streak++;
        } else {
            // Если сегодня МЫ выполнили, а вчера НЕТ -> стрик закончился (равен 1)
            // Если сегодня НЕ выполнили, а вчера ДА -> стрик продолжается (равен тому что было до вчера)
            // Если и сегодня НЕТ и вчера НЕТ -> стрик 0
            break;
        }
    }

    return streak;
}
