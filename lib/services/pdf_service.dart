// services/pdf_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  static const String _pdfFolder = 'reference_pdfs';

  /// Получить директорию для PDF файлов
  Future<Directory> _getPdfDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${appDir.path}/$_pdfFolder');

    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }

    return pdfDir;
  }

  /// Скопировать PDF из assets в локальное хранилище
  Future<String> copyPdfFromAssets(String assetPath, String fileName) async {
    try {
      final pdfDir = await _getPdfDirectory();
      final localPath = '${pdfDir.path}/$fileName';

      // Проверяем, не существует ли файл уже
      final localFile = File(localPath);
      if (await localFile.exists()) {
        return localPath;
      }

      // Копируем файл из assets
      final byteData = await rootBundle.load(assetPath);
      await localFile.writeAsBytes(byteData.buffer.asUint8List());

      return localPath;
    } catch (e) {
      throw Exception('Ошибка копирования PDF: $e');
    }
  }

  /// Извлечь текст из PDF файла
  Future<String> extractTextFromPdf(String pdfPath) async {
    try {
      final file = File(pdfPath);
      if (!await file.exists()) {
        throw Exception('PDF файл не найден: $pdfPath');
      }

      // Читаем файл как байты
      final bytes = await file.readAsBytes();

      // Загружаем PDF документ
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Извлекаем текст
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();

      // Освобождаем ресурсы
      document.dispose();

      return text.trim();
    } catch (e) {
      throw Exception('Ошибка извлечения текста из PDF: $e');
    }
  }

  /// Проверить существование PDF файла
  Future<bool> pdfExists(String pdfPath) async {
    try {
      final file = File(pdfPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Получить размер PDF файла
  Future<int> getPdfSize(String pdfPath) async {
    try {
      final file = File(pdfPath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Удалить PDF файл
  Future<bool> deletePdf(String pdfPath) async {
    try {
      final file = File(pdfPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Получить список всех PDF файлов
  Future<List<String>> getAllPdfFiles() async {
    try {
      final pdfDir = await _getPdfDirectory();
      final files = await pdfDir.list().toList();

      return files
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.pdf'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      return [];
    }
  }
}