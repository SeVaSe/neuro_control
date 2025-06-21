import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../entities/gmfcs.dart';

class GMFCSDAO {
  final AppDatabase _database = AppDatabase();

  // upsert
  Future<int> upsert(GMFCS gmfcs) async {
    final db = await _database.database;
    return await db.insert(
      'gmfcs',
      gmfcs.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<GMFCS?> getByPatient(String patientId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gmfcs',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
    return maps.isNotEmpty ? GMFCS.fromMap(maps.first) : null;
  }

  Future<int> deleteByPatient(String patientId) async {
    final db = await _database.database;
    return await db.delete(
      'gmfcs',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }
}
