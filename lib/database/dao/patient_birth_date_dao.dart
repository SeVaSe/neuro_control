// lib/database/dao/patient_birth_date_dao.dart

import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../entities/patient_birth_date.dart';

class PatientBirthDateDAO {
  Future<Database> get _database => AppDatabase().database;

  /// Создать или обновить дату рождения пациента (upsert)
  Future<int> upsert(PatientBirthDate patientBirthDate) async {
    final db = await _database;
    return await db.insert(
      'patient_birth_date',
      patientBirthDate.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Получить дату рождения пациента по ID
  Future<PatientBirthDate?> getByPatient(String patientId) async {
    final db = await _database;
    final maps = await db.query(
      'patient_birth_date',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return PatientBirthDate.fromMap(maps.first);
    }
    return null;
  }

  /// Обновить дату рождения пациента
  Future<int> update(PatientBirthDate patientBirthDate) async {
    final db = await _database;
    return await db.update(
      'patient_birth_date',
      patientBirthDate.toMap(),
      where: 'patient_id = ?',
      whereArgs: [patientBirthDate.patientId],
    );
  }

  /// Удалить дату рождения пациента
  Future<int> deleteByPatient(String patientId) async {
    final db = await _database;
    return await db.delete(
      'patient_birth_date',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }

  /// Получить все записи дат рождения
  Future<List<PatientBirthDate>> getAll() async {
    final db = await _database;
    final maps = await db.query('patient_birth_date');
    return maps.map((map) => PatientBirthDate.fromMap(map)).toList();
  }
}