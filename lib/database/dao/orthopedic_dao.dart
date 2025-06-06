import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../entities/orthopedic_examination.dart';
import '../entities/xray_image.dart';
import '../entities/xray_chart.dart';
import '../entities/photo_record.dart';

class OrthopedicDAO {
  final AppDatabase _database = AppDatabase();

  // Ортопедические осмотры
  Future<int> insertExamination(OrthopedicExamination examination) async {
    final db = await _database.database;
    return await db.insert('orthopedic_examinations', examination.toMap());
  }

  Future<List<OrthopedicExamination>> getExaminationsByPatient(String patientId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orthopedic_examinations',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => OrthopedicExamination.fromMap(map)).toList();
  }

  Future<OrthopedicExamination?> getExaminationById(int id) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orthopedic_examinations',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? OrthopedicExamination.fromMap(maps.first) : null;
  }

  Future<int> updateExamination(OrthopedicExamination examination) async {
    final db = await _database.database;
    return await db.update(
      'orthopedic_examinations',
      examination.toMap(),
      where: 'id = ?',
      whereArgs: [examination.id],
    );
  }

  Future<int> deleteExamination(int id) async {
    final db = await _database.database;
    return await db.delete(
      'orthopedic_examinations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Рентгеновские снимки
  Future<int> insertXrayImage(XrayImage xrayImage) async {
    final db = await _database.database;
    return await db.insert('xray_images', xrayImage.toMap());
  }

  Future<List<XrayImage>> getXrayImagesByExamination(int examinationId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'xray_images',
      where: 'orthopedic_examination_id = ?',
      whereArgs: [examinationId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => XrayImage.fromMap(map)).toList();
  }

  Future<int> deleteXrayImage(int id) async {
    final db = await _database.database;
    return await db.delete(
      'xray_images',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Графики рентгенов
  Future<int> insertXrayChart(XrayChart xrayChart) async {
    final db = await _database.database;
    return await db.insert('xray_charts', xrayChart.toMap());
  }

  Future<List<XrayChart>> getXrayChartsByExamination(int examinationId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'xray_charts',
      where: 'orthopedic_examination_id = ?',
      whereArgs: [examinationId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => XrayChart.fromMap(map)).toList();
  }

  Future<int> deleteXrayChart(int id) async {
    final db = await _database.database;
    return await db.delete(
      'xray_charts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Фото картотека
  Future<int> insertPhotoRecord(PhotoRecord photoRecord) async {
    final db = await _database.database;
    return await db.insert('photo_records', photoRecord.toMap());
  }

  Future<List<PhotoRecord>> getPhotoRecordsByExamination(int examinationId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'photo_records',
      where: 'orthopedic_examination_id = ?',
      whereArgs: [examinationId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => PhotoRecord.fromMap(map)).toList();
  }

  Future<int> deletePhotoRecord(int id) async {
    final db = await _database.database;
    return await db.delete(
      'photo_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
