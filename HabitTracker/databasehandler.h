#ifndef DATABASEHANDLER_H
#define DATABASEHANDLER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QDate>

class DatabaseHandler : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseHandler(QObject *parent = nullptr);
    ~DatabaseHandler();

    Q_INVOKABLE void connectToDatabase();
    Q_INVOKABLE bool addHabit(const QString &name, const QString &description, int frequency);
    Q_INVOKABLE bool updateHabit(int id, const QString &name, const QString &description, int frequency);
    Q_INVOKABLE QList<QString> getHabits();

    // ИЗМЕНЕНО: Теперь принимаем строку даты (dateString), чтобы отмечать задним числом
    Q_INVOKABLE void checkHabit(int id, const QString &dateString, bool checked);
    Q_INVOKABLE bool isHabitCompleted(int id, const QString &dateString);

    Q_INVOKABLE void removeHabit(int id);

    // ИЗМЕНЕНО: Более продвинутая статистика
    Q_INVOKABLE int getTotalCompletions(int id);
    Q_INVOKABLE int getCurrentStreak(int id); // Считает серию выполнений

private:
    QSqlDatabase m_db;
};

#endif // DATABASEHANDLER_H
