import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../entities/densitometry.dart';

class DensitometryDAO {
  final AppDatabase _database = AppDatabase();

  Future<int> insert(Densitometry densitometry) async {
    final db = await _database.database;
    return await db.insert('densitometry', densitometry.toMap());
  }

  Future<List<Densitometry>> getByPatient(String patientId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'densitometry',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Densitometry.fromMap(map)).toList();
  }

  Future<Densitometry?> getById(int id) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'densitometry',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Densitometry.fromMap(maps.first) : null;
  }

  Future<int> update(Densitometry densitometry) async {
    final db = await _database.database;
    return await db.update(
      'densitometry',
      densitometry.toMap(),
      where: 'id = ?',
      whereArgs: [densitometry.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _database.database;
    return await db.delete(
      'densitometry',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
