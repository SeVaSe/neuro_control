import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../entities/motor_skills_calendar.dart';

class MotorSkillsCalendarDAO {
  final AppDatabase _database = AppDatabase();

  Future<int> insert(MotorSkillsCalendar motorSkill) async {
    final db = await _database.database;
    return await db.insert('motor_skills_calendar', motorSkill.toMap());
  }

  Future<List<MotorSkillsCalendar>> getByPatient(String patientId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'motor_skills_calendar',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'skill_date DESC',
    );
    return maps.map((map) => MotorSkillsCalendar.fromMap(map)).toList();
  }

  Future<List<MotorSkillsCalendar>> getByPatientAndDateRange(
      String patientId,
      DateTime startDate,
      DateTime endDate
      ) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'motor_skills_calendar',
      where: 'patient_id = ? AND skill_date >= ? AND skill_date <= ?',
      whereArgs: [
        patientId,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch
      ],
      orderBy: 'skill_date ASC',
    );
    return maps.map((map) => MotorSkillsCalendar.fromMap(map)).toList();
  }

  Future<MotorSkillsCalendar?> getById(int id) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'motor_skills_calendar',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? MotorSkillsCalendar.fromMap(maps.first) : null;
  }

  Future<int> update(MotorSkillsCalendar motorSkill) async {
    final db = await _database.database;
    return await db.update(
      'motor_skills_calendar',
      motorSkill.toMap(),
      where: 'id = ?',
      whereArgs: [motorSkill.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _database.database;
    return await db.delete(
      'motor_skills_calendar',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Дополнительный метод для получения навыков по конкретной дате
  Future<List<MotorSkillsCalendar>> getByPatientAndDate(
      String patientId,
      DateTime date
      ) async {
    final db = await _database.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'motor_skills_calendar',
      where: 'patient_id = ? AND skill_date >= ? AND skill_date <= ?',
      whereArgs: [
        patientId,
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch
      ],
      orderBy: 'skill_date ASC',
    );
    return maps.map((map) => MotorSkillsCalendar.fromMap(map)).toList();
  }
}
