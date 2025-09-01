// database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  factory AppDatabase() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'medical_app.db');

    return await openDatabase(
      path,
      version: 5, // Увеличили версию для обновления таблицы напоминаний
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Таблица ортопедических осмотров
    await db.execute('''
      CREATE TABLE orthopedic_examinations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Таблица рентгеновских снимков
    await db.execute('''
      CREATE TABLE xray_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orthopedic_examination_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (orthopedic_examination_id) REFERENCES orthopedic_examinations (id) ON DELETE CASCADE
      )
    ''');

    // Таблица графиков рентгенов
    await db.execute('''
      CREATE TABLE xray_charts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orthopedic_examination_id INTEGER NOT NULL,
        chart_data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (orthopedic_examination_id) REFERENCES orthopedic_examinations (id) ON DELETE CASCADE
      )
    ''');

    // Таблица фото картотеки
    await db.execute('''
      CREATE TABLE photo_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orthopedic_examination_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (orthopedic_examination_id) REFERENCES orthopedic_examinations (id) ON DELETE CASCADE
      )
    ''');

    // Таблица денситометрии
    await db.execute('''
      CREATE TABLE densitometry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        image_path TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Таблица слюнотечения
    await db.execute('''
      CREATE TABLE salivation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        complication_score INTEGER NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Таблица GMFCS — хранит только текущее значение уровня
    await db.execute('''
      CREATE TABLE gmfcs (
        patient_id TEXT PRIMARY KEY,
        level INTEGER NOT NULL CHECK (level >= 1 AND level <= 5)
      )
    ''');

    await db.execute('''
      CREATE TABLE motor_skills_calendar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        skill_date INTEGER NOT NULL,
        skill_description TEXT NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Таблица для хранения даты рождения пациентов
    await db.execute('''
      CREATE TABLE patient_birth_date (
        patient_id TEXT PRIMARY KEY,
        birth_date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // ОБНОВЛЕННАЯ ТАБЛИЦА: Таблица напоминаний с новыми полями
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        event_date_time INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        notify_month_before INTEGER,
        notify_2weeks_before INTEGER,
        notify_day_before INTEGER,
        notify_hour_before INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_completed INTEGER DEFAULT 0 CHECK (is_completed IN (0, 1)),
        is_notification_sent INTEGER DEFAULT 0 CHECK (is_notification_sent IN (0, 1)),
        is_month_sent INTEGER DEFAULT 0 CHECK (is_month_sent IN (0, 1)),
        is_2weeks_sent INTEGER DEFAULT 0 CHECK (is_2weeks_sent IN (0, 1)),
        is_day_sent INTEGER DEFAULT 0 CHECK (is_day_sent IN (0, 1)),
        is_hour_sent INTEGER DEFAULT 0 CHECK (is_hour_sent IN (0, 1))
      )
    ''');

    // Таблица справочника
    await db.execute('''
      CREATE TABLE reference_guide (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Таблица фотографий для справочника
    await db.execute('''
      CREATE TABLE reference_guide_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference_guide_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        description TEXT,
        order_index INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (reference_guide_id) REFERENCES reference_guide (id) ON DELETE CASCADE
      )
    ''');

    // Таблица инструкций по эксплуатации
    await db.execute('''
      CREATE TABLE operation_manual (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Таблица фотографий для инструкций
    await db.execute('''
      CREATE TABLE operation_manual_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_manual_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        description TEXT,
        order_index INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (operation_manual_id) REFERENCES operation_manual (id) ON DELETE CASCADE
      )
    ''');

    // Индексы для оптимизации запросов
    await db.execute('CREATE INDEX idx_orthopedic_patient ON orthopedic_examinations(patient_id)');
    await db.execute('CREATE INDEX idx_xray_images_exam ON xray_images(orthopedic_examination_id)');
    await db.execute('CREATE INDEX idx_xray_charts_exam ON xray_charts(orthopedic_examination_id)');
    await db.execute('CREATE INDEX idx_photo_records_exam ON photo_records(orthopedic_examination_id)');
    await db.execute('CREATE INDEX idx_densitometry_patient ON densitometry(patient_id)');
    await db.execute('CREATE INDEX idx_salivation_patient ON salivation(patient_id)');
    await db.execute('CREATE INDEX idx_gmfcs_patient ON gmfcs(patient_id)');
    await db.execute('CREATE INDEX idx_motor_skills_patient ON motor_skills_calendar(patient_id)');
    await db.execute('CREATE INDEX idx_motor_skills_date ON motor_skills_calendar(skill_date)');
    await db.execute('CREATE INDEX idx_patient_birth_date ON patient_birth_date(patient_id)');
    await db.execute('CREATE INDEX idx_reference_guide_category ON reference_guide(category)');
    await db.execute('CREATE INDEX idx_reference_images_guide ON reference_guide_images(reference_guide_id)');
    await db.execute('CREATE INDEX idx_operation_manual_category ON operation_manual(category)');
    await db.execute('CREATE INDEX idx_operation_images_manual ON operation_manual_images(operation_manual_id)');

    // ОБНОВЛЕННЫЕ ИНДЕКСЫ для таблицы напоминаний
    await db.execute('CREATE INDEX idx_reminders_patient ON reminders(patient_id)');
    await db.execute('CREATE INDEX idx_reminders_datetime ON reminders(event_date_time)');
    await db.execute('CREATE INDEX idx_reminders_completed ON reminders(is_completed)');
    await db.execute('CREATE INDEX idx_reminders_notification ON reminders(is_notification_sent)');
    await db.execute('CREATE INDEX idx_reminders_patient_datetime ON reminders(patient_id, event_date_time)');
    await db.execute('CREATE INDEX idx_reminders_notify_month ON reminders(notify_month_before)');
    await db.execute('CREATE INDEX idx_reminders_notify_2weeks ON reminders(notify_2weeks_before)');
    await db.execute('CREATE INDEX idx_reminders_notify_day ON reminders(notify_day_before)');
    await db.execute('CREATE INDEX idx_reminders_notify_hour ON reminders(notify_hour_before)');

    await _insertInitialReferenceGuides(db);
    await _insertInitialInstructions(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Добавляем таблицу календаря моторных навыков
      await db.execute('''
      CREATE TABLE motor_skills_calendar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        skill_date INTEGER NOT NULL,
        skill_description TEXT NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    }

    if (oldVersion < 3) {
      // Добавляем таблицу справочника
      await db.execute('''
      CREATE TABLE reference_guide (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

      // Добавляем новую таблицу для даты рождения пациентов
      await db.execute('''
      CREATE TABLE patient_birth_date (
        patient_id TEXT PRIMARY KEY,
        birth_date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

      // Индексы для производительности
      await db.execute('CREATE INDEX idx_motor_skills_patient ON motor_skills_calendar(patient_id)');
      await db.execute('CREATE INDEX idx_motor_skills_date ON motor_skills_calendar(skill_date)');
      await db.execute('CREATE INDEX idx_patient_birth_date ON patient_birth_date(patient_id)');
      await db.execute('CREATE INDEX idx_reference_guide_category ON reference_guide(category)');
      await db.execute('CREATE INDEX idx_reference_images_guide ON reference_guide_images(reference_guide_id)');
      await db.execute('CREATE INDEX idx_operation_manual_category ON operation_manual(category)');
      await db.execute('CREATE INDEX idx_operation_images_manual ON operation_manual_images(operation_manual_id)');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          patient_id TEXT NOT NULL,
          reminder_date_time INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          is_completed INTEGER DEFAULT 0 CHECK (is_completed IN (0, 1)),
          is_notification_sent INTEGER DEFAULT 0 CHECK (is_notification_sent IN (0, 1))
        )
      ''');

      // Индексы для таблицы напоминаний
      await db.execute('CREATE INDEX idx_reminders_patient ON reminders(patient_id)');
      await db.execute('CREATE INDEX idx_reminders_datetime ON reminders(reminder_date_time)');
      await db.execute('CREATE INDEX idx_reminders_completed ON reminders(is_completed)');
      await db.execute('CREATE INDEX idx_reminders_notification ON reminders(is_notification_sent)');
      await db.execute('CREATE INDEX idx_reminders_patient_datetime ON reminders(patient_id, reminder_date_time)');
    }

    // НОВОЕ: Обновляем таблицу напоминаний в версии 5
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE reminders RENAME COLUMN reminder_date_time TO event_date_time;');
      await db.execute('ALTER TABLE reminders ADD COLUMN notify_month_before INTEGER;');
      await db.execute('ALTER TABLE reminders ADD COLUMN notify_2weeks_before INTEGER;');
      await db.execute('ALTER TABLE reminders ADD COLUMN notify_day_before INTEGER;');
      await db.execute('ALTER TABLE reminders ADD COLUMN notify_hour_before INTEGER;');
      await db.execute('ALTER TABLE reminders ADD COLUMN is_month_sent INTEGER DEFAULT 0;');
      await db.execute('ALTER TABLE reminders ADD COLUMN is_2weeks_sent INTEGER DEFAULT 0;');
      await db.execute('ALTER TABLE reminders ADD COLUMN is_day_sent INTEGER DEFAULT 0;');
      await db.execute('ALTER TABLE reminders ADD COLUMN is_hour_sent INTEGER DEFAULT 0;');

      // Обновляем индексы, если нужно
      await db.execute('DROP INDEX IF EXISTS idx_reminders_datetime;');
      await db.execute('CREATE INDEX idx_reminders_datetime ON reminders(event_date_time);');
      await db.execute('CREATE INDEX idx_reminders_notify_month ON reminders(notify_month_before);');
      await db.execute('CREATE INDEX idx_reminders_notify_2weeks ON reminders(notify_2weeks_before);');
      await db.execute('CREATE INDEX idx_reminders_notify_day ON reminders(notify_day_before);');
      await db.execute('CREATE INDEX idx_reminders_notify_hour ON reminders(notify_hour_before);');
    }
  }

  Future<void> _insertInitialReferenceGuides(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final guides = [
      {
        'title': 'Что такое ДЦП?',
        'content': 'Детский церебральный паралич — это группа двигательных нарушений...',
        'category': 'Общие сведения',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Методы реабилитации при ДЦП',
        'content': 'Включают ЛФК, робототерапию, физиотерапию, и ортезирование.',
        'category': 'Реабилитация',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Роль ортопедии в нейроразвитии',
        'content': 'Ортопедические методы важны для контроля за формированием скелета и осанки.',
        'category': 'Ортопедия',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Что такое ДЦП?',
        'content': 'Детский церебральный паралич — это группа двигательных нарушений...',
        'category': 'Общие сведения',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Методы реабилитации при ДЦП',
        'content': 'Включают ЛФК, робототерапию, физиотерапию, и ортезирование.',
        'category': 'Реабилитация',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Роль ортопедии в нейроразвитии',
        'content': 'Ортопедические методы важны для контроля за формированием скелета и осанки.',
        'category': 'Ортопедия',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Что такое ДЦП?',
        'content': 'Детский церебральный паралич — это группа двигательных нарушений...',
        'category': 'Общие сведения',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Методы реабилитации при ДЦП',
        'content': 'Включают ЛФК, робототерапию, физиотерапию, и ортезирование.',
        'category': 'Реабилитация',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Роль ортопедии в нейроразвитии',
        'content': 'Ортопедические методы важны для контроля за формированием скелета и осанки.',
        'category': 'Ортопедия',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Что такое ДЦП?',
        'content': 'Детский церебральный паралич — это группа двигательных нарушений...',
        'category': 'Общие сведения',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Методы реабилитации при ДЦП',
        'content': 'Включают ЛФК, робототерапию, физиотерапию, и ортезирование.',
        'category': 'Реабилитация',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Роль ортопедии в нейроразвитии',
        'content': 'Ортопедические методы важны для контроля за формированием скелета и осанки.',
        'category': 'Ортопедия',
        'created_at': now,
        'updated_at': now,
      },
      // Добавь другие записи при необходимости
    ];

    final batch = db.batch();

    for (final guide in guides) {
      batch.insert('reference_guide', guide);
    }

    await batch.commit(noResult: true);
  }

  Future<void> _insertInitialInstructions(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final guides = [
      {
        'title': 'Домашнее окно',
        'description': 'В главном окне у нас есть...',
        'category': 'Главное',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Раздел "О программе"',
        'description': 'Можно узнать все о...',
        'category': 'Разделы',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Раздел "Справочник"',
        'description': 'Узнайте о медицинских патологиях больше...',
        'category': 'Разделы',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Домашнее окно',
        'description': 'В главном окне у нас есть...',
        'category': 'Главное',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Раздел "О программе"',
        'description': 'Можно узнать все о...',
        'category': 'Разделы',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Раздел "Справочник"',
        'description': 'Узнайте о медицинских патологиях больше...',
        'category': 'Разделы',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Домашнее окно',
        'description': 'В главном окне у нас есть...',
        'category': 'Главное',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Раздел "О программе"',
        'description': 'Можно узнать все о...',
        'category': 'Разделы',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Раздел "Справочник"',
        'description': 'Узнайте о медицинских патологиях больше...',
        'category': 'Разделы',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Домашнее окно',
        'description': 'В главном окне у нас есть...',
        'category': 'Главное',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Раздел "О программе"',
        'description': 'Можно узнать все о...',
        'category': 'Разделы',
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Раздел "Справочник"',
        'description': 'Узнайте о медицинских патологиях больше...',
        'category': 'Разделы',
        'created_at': now,
        'updated_at': now,
      },
      // Добавь другие записи при необходимости
    ];

    final batch = db.batch();

    for (final guide in guides) {
      batch.insert('operation_manual', guide);
    }

    await batch.commit(noResult: true);
  }

  // Отдельный метод для закрытия БД
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Метод для удаления БД (например, при сбросе или разработке)
  Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'medical_app.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}