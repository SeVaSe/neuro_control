// reminder.dart
// lib/database/entities/reminder.dart
class Reminder {
  final int? id;
  final String patientId;
  final DateTime eventDateTime;
  final String title;
  final String? description;
  final DateTime? notifyMonthBefore;
  final DateTime? notify2WeeksBefore;
  final DateTime? notifyDayBefore;
  final DateTime? notifyHourBefore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final bool isNotificationSent;
  final bool isMonthSent;
  final bool is2WeeksSent;
  final bool isDaySent;
  final bool isHourSent;

  const Reminder({
    this.id,
    required this.patientId,
    required this.eventDateTime,
    required this.title,
    this.description,
    this.notifyMonthBefore,
    this.notify2WeeksBefore,
    this.notifyDayBefore,
    this.notifyHourBefore,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.isNotificationSent = false,
    this.isMonthSent = false,
    this.is2WeeksSent = false,
    this.isDaySent = false,
    this.isHourSent = false,
  });

  /// Создать объект из Map (из базы данных)
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      patientId: map['patient_id'],
      eventDateTime: DateTime.fromMillisecondsSinceEpoch(map['event_date_time']),
      title: map['title'],
      description: map['description'],
      notifyMonthBefore: map['notify_month_before'] != null ? DateTime.fromMillisecondsSinceEpoch(map['notify_month_before']) : null,
      notify2WeeksBefore: map['notify_2weeks_before'] != null ? DateTime.fromMillisecondsSinceEpoch(map['notify_2weeks_before']) : null,
      notifyDayBefore: map['notify_day_before'] != null ? DateTime.fromMillisecondsSinceEpoch(map['notify_day_before']) : null,
      notifyHourBefore: map['notify_hour_before'] != null ? DateTime.fromMillisecondsSinceEpoch(map['notify_hour_before']) : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      isCompleted: map['is_completed'] == 1,
      isNotificationSent: map['is_notification_sent'] == 1,
      isMonthSent: map['is_month_sent'] == 1,
      is2WeeksSent: map['is_2weeks_sent'] == 1,
      isDaySent: map['is_day_sent'] == 1,
      isHourSent: map['is_hour_sent'] == 1,
    );
  }

  /// Преобразовать объект в Map (для записи в базу данных)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId,
      'event_date_time': eventDateTime.millisecondsSinceEpoch,
      'title': title,
      'description': description,
      'notify_month_before': notifyMonthBefore?.millisecondsSinceEpoch,
      'notify_2weeks_before': notify2WeeksBefore?.millisecondsSinceEpoch,
      'notify_day_before': notifyDayBefore?.millisecondsSinceEpoch,
      'notify_hour_before': notifyHourBefore?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_completed': isCompleted ? 1 : 0,
      'is_notification_sent': isNotificationSent ? 1 : 0,
      'is_month_sent': isMonthSent ? 1 : 0,
      'is_2weeks_sent': is2WeeksSent ? 1 : 0,
      'is_day_sent': isDaySent ? 1 : 0,
      'is_hour_sent': isHourSent ? 1 : 0,
    };
  }

  /// Создать копию объекта с возможностью изменения полей
  Reminder copyWith({
    int? id,
    String? patientId,
    DateTime? eventDateTime,
    String? title,
    String? description,
    DateTime? notifyMonthBefore,
    DateTime? notify2WeeksBefore,
    DateTime? notifyDayBefore,
    DateTime? notifyHourBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    bool? isNotificationSent,
    bool? isMonthSent,
    bool? is2WeeksSent,
    bool? isDaySent,
    bool? isHourSent,
  }) {
    return Reminder(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      eventDateTime: eventDateTime ?? this.eventDateTime,
      title: title ?? this.title,
      description: description ?? this.description,
      notifyMonthBefore: notifyMonthBefore ?? this.notifyMonthBefore,
      notify2WeeksBefore: notify2WeeksBefore ?? this.notify2WeeksBefore,
      notifyDayBefore: notifyDayBefore ?? this.notifyDayBefore,
      notifyHourBefore: notifyHourBefore ?? this.notifyHourBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isNotificationSent: isNotificationSent ?? this.isNotificationSent,
      isMonthSent: isMonthSent ?? this.isMonthSent,
      is2WeeksSent: is2WeeksSent ?? this.is2WeeksSent,
      isDaySent: isDaySent ?? this.isDaySent,
      isHourSent: isHourSent ?? this.isHourSent,
    );
  }

  @override
  String toString() {
    return 'Reminder{'
        'id: $id, '
        'patientId: $patientId, '
        'eventDateTime: $eventDateTime, '
        'title: $title, '
        'description: $description, '
        'notifyMonthBefore: $notifyMonthBefore, '
        'notify2WeeksBefore: $notify2WeeksBefore, '
        'notifyDayBefore: $notifyDayBefore, '
        'notifyHourBefore: $notifyHourBefore, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'isCompleted: $isCompleted, '
        'isNotificationSent: $isNotificationSent, '
        'isMonthSent: $isMonthSent, '
        'is2WeeksSent: $is2WeeksSent, '
        'isDaySent: $isDaySent, '
        'isHourSent: $isHourSent'
        '}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder &&
        other.id == id &&
        other.patientId == patientId &&
        other.eventDateTime == eventDateTime &&
        other.title == title &&
        other.description == description &&
        other.notifyMonthBefore == notifyMonthBefore &&
        other.notify2WeeksBefore == notify2WeeksBefore &&
        other.notifyDayBefore == notifyDayBefore &&
        other.notifyHourBefore == notifyHourBefore &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isCompleted == isCompleted &&
        other.isNotificationSent == isNotificationSent &&
        other.isMonthSent == isMonthSent &&
        other.is2WeeksSent == is2WeeksSent &&
        other.isDaySent == isDaySent &&
        other.isHourSent == isHourSent;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      patientId,
      eventDateTime,
      title,
      description,
      notifyMonthBefore,
      notify2WeeksBefore,
      notifyDayBefore,
      notifyHourBefore,
      createdAt,
      updatedAt,
      isCompleted,
      isNotificationSent,
      isMonthSent,
      is2WeeksSent,
      isDaySent,
      isHourSent,
    );
  }

  /// Проверить, просрочено ли напоминание
  bool get isOverdue {
    return DateTime.now().isAfter(eventDateTime) && !isCompleted;
  }
}