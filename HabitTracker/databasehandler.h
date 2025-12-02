#ifndef DATABASEHANDLER_H
#define DATABASEHANDLER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QDate>

struct HabitStat {
    QString name;
    int completedCount;
};

class DatabaseHandler : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseHandler(QObject *parent = nullptr);
    ~DatabaseHandler();

    Q_INVOKABLE void connectToDatabase();
    Q_INVOKABLE bool addHabit(const QString &name, const QString &description);
    Q_INVOKABLE QList<QString> getHabits();
    Q_INVOKABLE void checkHabit(int id, bool checked);
    Q_INVOKABLE bool isHabitCompletedToday(int id);

    // Новое: для удаления и статистики
    Q_INVOKABLE void removeHabit(int id);
    Q_INVOKABLE int getTotalCompletions(int id);

private:
    QSqlDatabase m_db;
};

#endif // DATABASEHANDLER_H
