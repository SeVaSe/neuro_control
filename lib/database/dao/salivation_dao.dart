import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../entities/salivation.dart';

class SalivationDAO {
  final AppDatabase _database = AppDatabase();

  Future<int> insert(Salivation salivation) async {
    final db = await _database.database;
    return await db.insert('salivation', salivation.toMap());
  }

  Future<List<Salivation>> getByPatient(String patientId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'salivation',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Salivation.fromMap(map)).toList();
  }

  Future<Salivation?> getById(int id) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'salivation',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Salivation.fromMap(maps.first) : null;
  }

  Future<Salivation?> getLatestByPatient(String patientId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'salivation',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    return maps.isNotEmpty ? Salivation.fromMap(maps.first) : null;
  }

  Future<int> update(Salivation salivation) async {
    final db = await _database.database;
    return await db.update(
      'salivation',
      salivation.toMap(),
      where: 'id = ?',
      whereArgs: [salivation.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _database.database;
    return await db.delete(
      'salivation',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
