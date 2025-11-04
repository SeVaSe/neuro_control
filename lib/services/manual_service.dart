import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../models/operation_manual_model.dart';

class ManualService {
  static final ManualService _instance = ManualService._internal();
  factory ManualService() => _instance;
  ManualService._internal();

  List<OperationManualModel>? _cachedManuals;

  /// Загрузка всех инструкций из JSON файла
  Future<List<OperationManualModel>> getAllManuals() async {
    if (_cachedManuals != null) {
      return _cachedManuals!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'lib/assets/data/json/operation_manuals.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> manualsJson = jsonData['manuals'] ?? [];

      _cachedManuals = manualsJson
          .map((json) => OperationManualModel.fromJson(json))
          .toList();

      return _cachedManuals!;
    } catch (e) {
      debugPrint('Ошибка загрузки инструкций из JSON: $e');
      rethrow;
    }
  }

  /// Получение инструкции по ID
  Future<OperationManualModel?> getManualById(String id) async {
    final manuals = await getAllManuals();
    try {
      return manuals.firstWhere((manual) => manual.id == id);
    } catch (e) {
      debugPrint('Инструкция с ID $id не найдена');
      return null;
    }
  }

  /// Поиск инструкций по названию или категории
  Future<List<OperationManualModel>> searchManuals(String query) async {
    if (query.trim().isEmpty) {
      return getAllManuals();
    }

    final manuals = await getAllManuals();
    final lowerQuery = query.toLowerCase().trim();

    return manuals.where((manual) {
      return manual.title.toLowerCase().contains(lowerQuery) ||
          manual.category.toLowerCase().contains(lowerQuery) ||
          manual.shortDescription.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Получение всех категорий
  Future<List<String>> getAllCategories() async {
    final manuals = await getAllManuals();
    final categories = manuals.map((m) => m.category).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Фильтрация по категории
  Future<List<OperationManualModel>> getManualsByCategory(
      String category) async {
    final manuals = await getAllManuals();
    return manuals
        .where((manual) =>
    manual.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Очистка кэша
  void clearCache() {
    _cachedManuals = null;
  }
}