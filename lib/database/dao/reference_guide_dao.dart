import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../entities/reference_guide.dart';
import '../entities/reference_guide_image.dart';

class ReferenceGuideDAO {
  final AppDatabase _database = AppDatabase();

  // Справочник
  Future<int> insertGuide(ReferenceGuide guide) async {
    final db = await _database.database;
    return await db.insert('reference_guide', guide.toMap());
  }

  Future<List<ReferenceGuide>> getAllGuides() async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reference_guide',
      orderBy: 'title ASC',
    );
    return maps.map((map) => ReferenceGuide.fromMap(map)).toList();
  }

  Future<List<ReferenceGuide>> getGuidesByCategory(String category) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reference_guide',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'title ASC',
    );
    return maps.map((map) => ReferenceGuide.fromMap(map)).toList();
  }

  Future<ReferenceGuide?> getGuideById(int id) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reference_guide',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? ReferenceGuide.fromMap(maps.first) : null;
  }

  Future<int> updateGuide(ReferenceGuide guide) async {
    final db = await _database.database;
    return await db.update(
      'reference_guide',
      guide.toMap(),
      where: 'id = ?',
      whereArgs: [guide.id],
    );
  }

  Future<int> deleteGuide(int id) async {
    final db = await _database.database;
    return await db.delete(
      'reference_guide',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Изображения справочника
  Future<int> insertGuideImage(ReferenceGuideImage image) async {
    final db = await _database.database;
    return await db.insert('reference_guide_images', image.toMap());
  }

  Future<List<ReferenceGuideImage>> getImagesByGuide(int guideId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reference_guide_images',
      where: 'reference_guide_id = ?',
      whereArgs: [guideId],
      orderBy: 'order_index ASC, created_at ASC',
    );
    return maps.map((map) => ReferenceGuideImage.fromMap(map)).toList();
  }

  Future<int> deleteGuideImage(int id) async {
    final db = await _database.database;
    return await db.delete(
      'reference_guide_images',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Поиск по справочнику
  Future<List<ReferenceGuide>> searchGuides(String query) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reference_guide',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
    return maps.map((map) => ReferenceGuide.fromMap(map)).toList();
  }
}