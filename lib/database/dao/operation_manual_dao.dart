import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../entities/operation_manual.dart';
import '../entities/operation_manual_image.dart';

class OperationManualDAO {
  final AppDatabase _database = AppDatabase();

  // Инструкции
  Future<int> insertManual(OperationManual manual) async {
    final db = await _database.database;
    return await db.insert('operation_manual', manual.toMap());
  }

  Future<List<OperationManual>> getAllManuals() async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'operation_manual',
      orderBy: 'title ASC',
    );
    return maps.map((map) => OperationManual.fromMap(map)).toList();
  }

  Future<List<OperationManual>> getManualsByCategory(String category) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'operation_manual',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'title ASC',
    );
    return maps.map((map) => OperationManual.fromMap(map)).toList();
  }

  Future<OperationManual?> getManualById(int id) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'operation_manual',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? OperationManual.fromMap(maps.first) : null;
  }

  Future<int> updateManual(OperationManual manual) async {
    final db = await _database.database;
    return await db.update(
      'operation_manual',
      manual.toMap(),
      where: 'id = ?',
      whereArgs: [manual.id],
    );
  }

  Future<int> deleteManual(int id) async {
    final db = await _database.database;
    return await db.delete(
      'operation_manual',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Изображения инструкций
  Future<int> insertManualImage(OperationManualImage image) async {
    final db = await _database.database;
    return await db.insert('operation_manual_images', image.toMap());
  }

  Future<List<OperationManualImage>> getImagesByManual(int manualId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'operation_manual_images',
      where: 'operation_manual_id = ?',
      whereArgs: [manualId],
      orderBy: 'order_index ASC, created_at ASC',
    );
    return maps.map((map) => OperationManualImage.fromMap(map)).toList();
  }

  Future<int> deleteManualImage(int id) async {
    final db = await _database.database;
    return await db.delete(
      'operation_manual_images',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Поиск по инструкциям
  Future<List<OperationManual>> searchManuals(String query) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'operation_manual',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
    return maps.map((map) => OperationManual.fromMap(map)).toList();
  }
}
