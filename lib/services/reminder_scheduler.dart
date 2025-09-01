// lib/services/reminder_scheduler.dart
import '../../database/entities/reminder.dart';
import 'database_service.dart'; // Предполагается, что сервис находится в этом файле

class ReminderScheduler {
  final DatabaseService _databaseService;

  ReminderScheduler(this._databaseService);

  /// Создает напоминание с автоматическим расчетом дат уведомлений
  Future<int> scheduleReminder({
    required String patientId,
    required DateTime appointmentDateTime,
    required String title,
    String? description,
  }) async {
    final now = DateTime.now();
    DateTime? notifyMonthBefore;
    DateTime? notify2WeeksBefore;
    DateTime? notifyDayBefore;
    DateTime? notifyHourBefore;

    // Рассчитываем даты уведомлений в зависимости от текущей даты
    final daysUntilEvent = appointmentDateTime.difference(now).inDays;

    // Уведомление за месяц (если до события больше 30 дней)
    if (daysUntilEvent >= 30) {
      notifyMonthBefore = appointmentDateTime.subtract(const Duration(days: 30));
    }

    // Уведомление за 2 недели (если до события больше 14 дней)
    if (daysUntilEvent >= 14) {
      notify2WeeksBefore = appointmentDateTime.subtract(const Duration(days: 14));
    }

    // Уведомление за день (если до события больше 1 дня)
    if (daysUntilEvent >= 1) {
      notifyDayBefore = appointmentDateTime.subtract(const Duration(days: 1));
    }

    // Уведомление за час
    notifyHourBefore = appointmentDateTime.subtract(const Duration(hours: 1));

    // Создаем напоминание через сервис
    return await _databaseService.createReminder(
      patientId,
      appointmentDateTime,
      title,
      description: description,
      notifyMonthBefore: notifyMonthBefore,
      notify2WeeksBefore: notify2WeeksBefore,
      notifyDayBefore: notifyDayBefore,
      notifyHourBefore: notifyHourBefore,
    );
  }
}