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

    // Подключение к БД
    Q_INVOKABLE void connectToDatabase();

    // Добавление новой привычки
    Q_INVOKABLE bool addHabit(const QString &name, const QString &description);

    // Получение списка привычек (для простоты вернем список строк "ID: Имя")
    // В серьезном проекте здесь используют QAbstractListModel
    Q_INVOKABLE QList<QString> getHabits();

    // Отметить привычку выполненной на сегодня
    Q_INVOKABLE void checkHabit(int id, bool checked);

    // Проверить, выполнена ли привычка сегодня
    Q_INVOKABLE bool isHabitCompletedToday(int id);

private:
    QSqlDatabase m_db;
};

#endif // DATABASEHANDLER_H
