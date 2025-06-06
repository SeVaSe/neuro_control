import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../entities/gmfcs.dart';

class GMFCSDAO {
  final AppDatabase _database = AppDatabase();

  Future<int> insert(GMFCS gmfcs) async {
    final db = await _database.database;
    return await db.insert('gmfcs', gmfcs.toMap());
  }

  Future<List<GMFCS>> getByPatient(String patientId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gmfcs',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => GMFCS.fromMap(map)).toList();
  }

  Future<GMFCS?> getById(int id) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gmfcs',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? GMFCS.fromMap(maps.first) : null;
  }

  Future<GMFCS?> getLatestByPatient(String patientId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gmfcs',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    return maps.isNotEmpty ? GMFCS.fromMap(maps.first) : null;
  }

  Future<int> update(GMFCS gmfcs) async {
    final db = await _database.database;
    return await db.update(
      'gmfcs',
      gmfcs.toMap(),
      where: 'id = ?',
      whereArgs: [gmfcs.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _database.database;
    return await db.delete(
      'gmfcs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
