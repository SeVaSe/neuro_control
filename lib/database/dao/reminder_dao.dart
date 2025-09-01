// reminder_dao.dart
// lib/database/dao/reminder_dao.dart
import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../entities/reminder.dart';

class ReminderDAO {
  static final ReminderDAO _instance = ReminderDAO._internal();
  factory ReminderDAO() => _instance;
  ReminderDAO._internal();

  static const String tableName = 'reminders';

  /// Добавить новое напоминание
  Future<int> insert(Reminder reminder) async {
    final db = await AppDatabase().database;
    return await db.insert(tableName, reminder.toMap());
  }

  /// Получить напоминание по ID
  Future<Reminder?> getById(int id) async {
    final db = await AppDatabase().database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Reminder.fromMap(result.first);
  }

  /// Получить все напоминания пациента
  Future<List<Reminder>> getByPatient(String patientId) async {
    final db = await AppDatabase().database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'event_date_time ASC',
    );

    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  /// Получить активные (не завершенные) напоминания пациента
  Future<List<Reminder>> getActiveByPatient(String patientId) async {
    final db = await AppDatabase().database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'patient_id = ? AND is_completed = 0',
      whereArgs: [patientId],
      orderBy: 'event_date_time ASC',
    );

    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  /// Получить завершенные напоминания пациента
  Future<List<Reminder>> getCompletedByPatient(String patientId) async {
    final db = await AppDatabase().database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'patient_id = ? AND is_completed = 1',
      whereArgs: [patientId],
      orderBy: 'event_date_time DESC',
    );

    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  /// Получить напоминания за определенный период
  Future<List<Reminder>> getByPatientAndDateRange(
      String patientId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    final db = await AppDatabase().database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'patient_id = ? AND event_date_time >= ? AND event_date_time <= ?',
      whereArgs: [
        patientId,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'event_date_time ASC',
    );

    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  /// Получить просроченные напоминания пациента
  Future<List<Reminder>> getOverdueByPatient(String patientId) async {
    final db = await AppDatabase().database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'patient_id = ? AND is_completed = 0 AND event_date_time < ?',
      whereArgs: [patientId, now],
      orderBy: 'event_date_time ASC',
    );

    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  /// Получить предстоящие напоминания пациента (на следующие 24 часа)
  Future<List<Reminder>> getUpcomingByPatient(String patientId) async {
    final db = await AppDatabase().database;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'patient_id = ? AND is_completed = 0 AND event_date_time >= ? AND event_date_time <= ?',
      whereArgs: [
        patientId,
        now.millisecondsSinceEpoch,
        tomorrow.millisecondsSinceEpoch,
      ],
      orderBy: 'event_date_time ASC',
    );

    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  /// Получить напоминания, которые требуют отправки уведомления (учитывая все типы)
  Future<List<Reminder>> getNotificationPending() async {
    final db = await AppDatabase().database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'is_completed = 0 AND ('
          '(notify_month_before IS NOT NULL AND notify_month_before <= ? AND is_month_sent = 0) OR '
          '(notify_2weeks_before IS NOT NULL AND notify_2weeks_before <= ? AND is_2weeks_sent = 0) OR '
          '(notify_day_before IS NOT NULL AND notify_day_before <= ? AND is_day_sent = 0) OR '
          '(notify_hour_before IS NOT NULL AND notify_hour_before <= ? AND is_hour_sent = 0)'
          ')',
      whereArgs: [now, now, now, now],
      orderBy: 'event_date_time ASC',
    );

    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  /// Поиск напоминаний по заголовку
  Future<List<Reminder>> searchByTitle(String patientId, String query) async {
    final db = await AppDatabase().database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'patient_id = ? AND title LIKE ?',
      whereArgs: [patientId, '%$query%'],
      orderBy: 'event_date_time DESC',
    );

    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  /// Обновить напоминание
  Future<int> update(Reminder reminder) async {
    final db = await AppDatabase().database;
    return await db.update(
      tableName,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  /// Пометить напоминание как завершенное
  Future<int> markAsCompleted(int id) async {
    final db = await AppDatabase().database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.update(
      tableName,
      {
        'is_completed': 1,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Пометить конкретное уведомление как отправленное
  Future<int> markSpecificNotificationSent(int id, String type) async {
    final db = await AppDatabase().database;
    final now = DateTime.now().millisecondsSinceEpoch;
    String column;
    switch (type) {
      case 'month':
        column = 'is_month_sent';
        break;
      case '2weeks':
        column = 'is_2weeks_sent';
        break;
      case 'day':
        column = 'is_day_sent';
        break;
      case 'hour':
        column = 'is_hour_sent';
        break;
      default:
        throw Exception('Invalid notification type');
    }
    return await db.update(
      tableName,
      {
        column: 1,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Пометить уведомление как отправленное (для обратной совместимости)
  Future<int> markNotificationSent(int id) async {
    final db = await AppDatabase().database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.update(
      tableName,
      {
        'is_notification_sent': 1,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Удалить напоминание
  Future<int> delete(int id) async {
    final db = await AppDatabase().database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Удалить все напоминания пациента
  Future<int> deleteByPatient(String patientId) async {
    final db = await AppDatabase().database;
    return await db.delete(
      tableName,
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }

  /// Удалить завершенные напоминания старше указанного периода
  Future<int> deleteOldCompleted(Duration olderThan) async {
    final db = await AppDatabase().database;
    final cutoffDate = DateTime.now().subtract(olderThan);
    return await db.delete(
      tableName,
      where: 'is_completed = 1 AND updated_at < ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  /// Получить статистику напоминаний пациента
  Future<Map<String, int>> getStatsByPatient(String patientId) async {
    final db = await AppDatabase().database;

    // Общее количество
    final total = await db.query(
      tableName,
      columns: ['COUNT(*) as count'],
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );

    // Завершенные
    final completed = await db.query(
      tableName,
      columns: ['COUNT(*) as count'],
      where: 'patient_id = ? AND is_completed = 1',
      whereArgs: [patientId],
    );

    // Активные
    final active = await db.query(
      tableName,
      columns: ['COUNT(*) as count'],
      where: 'patient_id = ? AND is_completed = 0',
      whereArgs: [patientId],
    );

    // Просроченные
    final now = DateTime.now().millisecondsSinceEpoch;
    final overdue = await db.query(
      tableName,
      columns: ['COUNT(*) as count'],
      where: 'patient_id = ? AND is_completed = 0 AND event_date_time < ?',
      whereArgs: [patientId, now],
    );

    return {
      'total': total.first['count'] as int,
      'completed': completed.first['count'] as int,
      'active': active.first['count'] as int,
      'overdue': overdue.first['count'] as int,
    };
  }
}