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
      version: 2,
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

    // Таблица GMFCS
    await db.execute('''
      CREATE TABLE gmfcs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        level INTEGER NOT NULL CHECK (level >= 1 AND level <= 5),
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
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
    await db.execute('CREATE INDEX idx_reference_guide_category ON reference_guide(category)');
    await db.execute('CREATE INDEX idx_reference_images_guide ON reference_guide_images(reference_guide_id)');
    await db.execute('CREATE INDEX idx_operation_manual_category ON operation_manual(category)');
    await db.execute('CREATE INDEX idx_operation_images_manual ON operation_manual_images(operation_manual_id)');
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

      await db.execute('CREATE INDEX idx_motor_skills_patient ON motor_skills_calendar(patient_id)');
      await db.execute('CREATE INDEX idx_motor_skills_date ON motor_skills_calendar(skill_date)');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Метод для очистки БД (для разработки)
  Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'medical_app.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
