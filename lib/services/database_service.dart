// lib/services/database_service.dart
import 'package:neuro_control/services/pdf_service.dart';

import '../database/dao/orthopedic_dao.dart';
import '../database/dao/densitometry_dao.dart';
import '../database/dao/salivation_dao.dart';
import '../database/dao/gmfcs_dao.dart';
import '../database/dao/patient_birth_date_dao.dart';
import '../database/entities/orthopedic_examination.dart';
import '../database/entities/xray_image.dart';
import '../database/entities/xray_chart.dart';
import '../database/entities/photo_record.dart';
import '../database/entities/densitometry.dart';
import '../database/entities/salivation.dart';
import '../database/entities/gmfcs.dart';
import '../database/dao/motor_skills_calendar_dao.dart';
import '../database/dao/reference_guide_dao.dart';
import '../database/dao/operation_manual_dao.dart';
import '../database/entities/motor_skills_calendar.dart';
import '../database/entities/reference_guide.dart';
import '../database/entities/reference_guide_image.dart';
import '../database/entities/operation_manual.dart';
import '../database/entities/operation_manual_image.dart';
import '../database/entities/patient_birth_date.dart';
import '../database/entities/reminder.dart';
import '../database/dao/reminder_dao.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final OrthopedicDAO _orthopedicDAO = OrthopedicDAO();
  final DensitometryDAO _densitometryDAO = DensitometryDAO();
  final SalivationDAO _salivationDAO = SalivationDAO();
  final GMFCSDAO _gmfcsDAO = GMFCSDAO();
  final MotorSkillsCalendarDAO _motorSkillsDAO = MotorSkillsCalendarDAO();
  final ReferenceGuideDAO _referenceGuideDAO = ReferenceGuideDAO();
  final OperationManualDAO _operationManualDAO = OperationManualDAO();
  final PatientBirthDateDAO _patientBirthDateDAO = PatientBirthDateDAO();
  final ReminderDAO _reminderDAO = ReminderDAO();
  final PdfService _pdfService = PdfService();


  // =============================================================================
  // ОРТОПЕДИЧЕСКИЕ ОСМОТРЫ
  // =============================================================================

  /// Создать новый ортопедический осмотр
  Future<int> createOrthopedicExamination(String patientId) async {
    final now = DateTime.now();
    final examination = OrthopedicExamination(
      patientId: patientId,
      createdAt: now,
      updatedAt: now,
    );
    return await _orthopedicDAO.insertExamination(examination);
  }

  /// Получить все ортопедические осмотры пациента
  Future<List<OrthopedicExamination>> getOrthopedicExaminations(String patientId) async {
    return await _orthopedicDAO.getExaminationsByPatient(patientId);
  }

  /// Получить конкретный ортопедический осмотр
  Future<OrthopedicExamination?> getOrthopedicExamination(int id) async {
    return await _orthopedicDAO.getExaminationById(id);
  }

  /// Обновить ортопедический осмотр
  Future<bool> updateOrthopedicExamination(OrthopedicExamination examination) async {
    final updatedExamination = examination.copyWith(updatedAt: DateTime.now());
    final result = await _orthopedicDAO.updateExamination(updatedExamination);
    return result > 0;
  }

  /// Удалить ортопедический осмотр
  Future<bool> deleteOrthopedicExamination(int id) async {
    final result = await _orthopedicDAO.deleteExamination(id);
    return result > 0;
  }

  // =============================================================================
  // РЕНТГЕНОВСКИЕ СНИМКИ
  // =============================================================================

  /// Добавить рентгеновский снимок
  Future<int> addXrayImage(int examinationId, String imagePath, {String? description}) async {
    final xrayImage = XrayImage(
      orthopedicExaminationId: examinationId,
      imagePath: imagePath,
      description: description,
      createdAt: DateTime.now(),
    );
    return await _orthopedicDAO.insertXrayImage(xrayImage);
  }

  /// Получить все рентгеновские снимки для осмотра
  Future<List<XrayImage>> getXrayImages(int examinationId) async {
    return await _orthopedicDAO.getXrayImagesByExamination(examinationId);
  }

  /// Удалить рентгеновский снимок
  Future<bool> deleteXrayImage(int id) async {
    final result = await _orthopedicDAO.deleteXrayImage(id);
    return result > 0;
  }

  // =============================================================================
  // ГРАФИКИ РЕНТГЕНОВ
  // =============================================================================

  /// Добавить график рентгена
  Future<int> addXrayChart(int examinationId, String chartData) async {
    final xrayChart = XrayChart(
      orthopedicExaminationId: examinationId,
      chartData: chartData,
      createdAt: DateTime.now(),
    );
    return await _orthopedicDAO.insertXrayChart(xrayChart);
  }

  /// Получить все графики рентгенов для осмотра
  Future<List<XrayChart>> getXrayCharts(int examinationId) async {
    return await _orthopedicDAO.getXrayChartsByExamination(examinationId);
  }

  /// Удалить график рентгена
  Future<bool> deleteXrayChart(int id) async {
    final result = await _orthopedicDAO.deleteXrayChart(id);
    return result > 0;
  }

  // =============================================================================
  // ФОТО КАРТОТЕКА
  // =============================================================================

  /// Добавить фото в картотеку
  Future<int> addPhotoRecord(int examinationId, String imagePath, {String? description}) async {
    final photoRecord = PhotoRecord(
      orthopedicExaminationId: examinationId,
      imagePath: imagePath,
      description: description,
      createdAt: DateTime.now(),
    );
    return await _orthopedicDAO.insertPhotoRecord(photoRecord);
  }

  /// Получить все фото из картотеки для осмотра
  Future<List<PhotoRecord>> getPhotoRecords(int examinationId) async {
    return await _orthopedicDAO.getPhotoRecordsByExamination(examinationId);
  }

  /// Удалить фото из картотеки
  Future<bool> deletePhotoRecord(int id) async {
    final result = await _orthopedicDAO.deletePhotoRecord(id);
    return result > 0;
  }

  // =============================================================================
  // ДЕНСИТОМЕТРИЯ
  // =============================================================================

  /// Добавить денситометрию
  Future<int> addDensitometry(String patientId, String imagePath, {String? description}) async {
    final now = DateTime.now();
    final densitometry = Densitometry(
      patientId: patientId,
      imagePath: imagePath,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
    return await _densitometryDAO.insert(densitometry);
  }

  /// Получить все денситометрии пациента
  Future<List<Densitometry>> getDensitometries(String patientId) async {
    return await _densitometryDAO.getByPatient(patientId);
  }

  /// Получить конкретную денситометрию
  Future<Densitometry?> getDensitometry(int id) async {
    return await _densitometryDAO.getById(id);
  }

  /// Обновить денситометрию
  Future<bool> updateDensitometry(Densitometry densitometry) async {
    final updatedDensitometry = densitometry.copyWith(updatedAt: DateTime.now());
    final result = await _densitometryDAO.update(updatedDensitometry);
    return result > 0;
  }

  /// Удалить денситометрию
  Future<bool> deleteDensitometry(int id) async {
    final result = await _densitometryDAO.delete(id);
    return result > 0;
  }

  // =============================================================================
  // СЛЮНОТЕЧЕНИЕ
  // =============================================================================

  /// Добавить запись о слюнотечении
  Future<int> addSalivation(String patientId, int complicationScore, {String? notes}) async {
    final now = DateTime.now();
    final salivation = Salivation(
      patientId: patientId,
      complicationScore: complicationScore,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    return await _salivationDAO.insert(salivation);
  }

  /// Получить все записи о слюнотечении пациента
  Future<List<Salivation>> getSalivations(String patientId) async {
    return await _salivationDAO.getByPatient(patientId);
  }

  /// Получить последнюю запись о слюнотечении пациента
  Future<Salivation?> getLatestSalivation(String patientId) async {
    return await _salivationDAO.getLatestByPatient(patientId);
  }

  /// Получить конкретную запись о слюнотечении
  Future<Salivation?> getSalivation(int id) async {
    return await _salivationDAO.getById(id);
  }

  /// Обновить запись о слюнотечении
  Future<bool> updateSalivation(Salivation salivation) async {
    final updatedSalivation = salivation.copyWith(updatedAt: DateTime.now());
    final result = await _salivationDAO.update(updatedSalivation);
    return result > 0;
  }

  /// Удалить запись о слюнотечении
  Future<bool> deleteSalivation(int id) async {
    final result = await _salivationDAO.delete(id);
    return result > 0;
  }

  // =============================================================================
  // GMFCS — только текущее значение
  // =============================================================================

  /// Установить или обновить уровень GMFCS пациента
  Future<bool> setGMFCS(String patientId, int level) async {
    if (level < 1 || level > 5) {
      throw ArgumentError('GMFCS level должен быть от 1 до 5');
    }

    final gmfcs = GMFCS(patientId: patientId, level: level);
    final result = await _gmfcsDAO.upsert(gmfcs);
    return result > 0;
  }

  /// Получить текущий уровень GMFCS пациента
  Future<GMFCS?> getGMFCS(String patientId) async {
    return await _gmfcsDAO.getByPatient(patientId);
  }

  /// Удалить уровень GMFCS у пациента
  Future<bool> deleteGMFCS(String patientId) async {
    final result = await _gmfcsDAO.deleteByPatient(patientId);
    return result > 0;
  }


  // =============================================================================
  // КАЛЕНДАРЬ МОТОРНЫХ НАВЫКОВ
  // =============================================================================

  /// Добавить новый моторный навык
  Future<int> addMotorSkill(String patientId, DateTime skillDate, String skillDescription, {String? notes}) async {
    final now = DateTime.now();
    final motorSkill = MotorSkillsCalendar(
      patientId: patientId,
      skillDate: skillDate,
      skillDescription: skillDescription,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    return await _motorSkillsDAO.insert(motorSkill);
  }

  /// Получить все моторные навыки пациента
  Future<List<MotorSkillsCalendar>> getMotorSkills(String patientId) async {
    return await _motorSkillsDAO.getByPatient(patientId);
  }

  /// Получить моторные навыки пациента за период
  Future<List<MotorSkillsCalendar>> getMotorSkillsByDateRange(
      String patientId,
      DateTime startDate,
      DateTime endDate) async {
    return await _motorSkillsDAO.getByPatientAndDateRange(patientId, startDate, endDate);
  }

  /// Получить моторные навыки пациента за конкретную дату
  Future<List<MotorSkillsCalendar>> getMotorSkillsByDate(String patientId, DateTime date) async {
    return await _motorSkillsDAO.getByPatientAndDate(patientId, date);
  }

  /// Получить конкретный моторный навык
  Future<MotorSkillsCalendar?> getMotorSkill(int id) async {
    return await _motorSkillsDAO.getById(id);
  }

  /// Обновить моторный навык
  Future<bool> updateMotorSkill(MotorSkillsCalendar motorSkill) async {
    final updatedSkill = motorSkill.copyWith(updatedAt: DateTime.now());
    final result = await _motorSkillsDAO.update(updatedSkill);
    return result > 0;
  }

  /// Удалить моторный навык
  Future<bool> deleteMotorSkill(int id) async {
    final result = await _motorSkillsDAO.delete(id);
    return result > 0;
  }

  // =============================================================================
  // СПРАВОЧНИК
  // =============================================================================

  /// Добавить новую запись в справочник (БД)
  Future<int> addReferenceGuide(String title, String content, {String? category}) async {
    final now = DateTime.now();
    final guide = ReferenceGuide(
      title: title,
      content: content,
      category: category,
      createdAt: now,
      updatedAt: now,
      type: ReferenceType.database,
    );
    return await _referenceGuideDAO.insertGuide(guide);
  }

  /// Добавить PDF справочник
  Future<int> addPdfReferenceGuide({
    required String title,
    required String assetPdfPath,
    required String fileName,
    String? category,
  }) async {
    try {
      // Копируем PDF из assets
      final localPdfPath = await _pdfService.copyPdfFromAssets(assetPdfPath, fileName);

      // Создаем запись без контента (будет загружен позже)
      final guide = ReferenceGuide.fromPdf(
        title: title,
        pdfPath: localPdfPath,
        category: category,
      );

      return await _referenceGuideDAO.insertGuide(guide);
    } catch (e) {
      throw Exception('Ошибка добавления PDF справочника: $e');
    }
  }

  /// Получить все записи справочника (БД + PDF)
  Future<List<ReferenceGuide>> getAllReferenceGuides() async {
    final guides = await _referenceGuideDAO.getAllGuides();

    // Загружаем контент для PDF файлов, которые еще не загружены
    final updatedGuides = <ReferenceGuide>[];

    for (final guide in guides) {
      if (guide.needsContentLoading && guide.pdfPath != null) {
        try {
          final content = await _pdfService.extractTextFromPdf(guide.pdfPath!);
          final updatedGuide = guide.copyWith(
            content: content,
            isPdfLoaded: true,
            updatedAt: DateTime.now(),
          );

          // Обновляем в БД
          await _referenceGuideDAO.updateGuide(updatedGuide);
          updatedGuides.add(updatedGuide);
        } catch (e) {
          // Если ошибка загрузки PDF, добавляем как есть с пометкой об ошибке
          final errorGuide = guide.copyWith(
            content: 'Ошибка загрузки PDF: $e',
            isPdfLoaded: false,
          );
          updatedGuides.add(errorGuide);
        }
      } else {
        updatedGuides.add(guide);
      }
    }

    return updatedGuides;
  }

  /// Получить записи справочника по категории
  Future<List<ReferenceGuide>> getReferenceGuidesByCategory(String category) async {
    final guides = await _referenceGuideDAO.getGuidesByCategory(category);
    return await _loadPdfContentIfNeeded(guides);
  }

  /// Получить конкретную запись справочника
  Future<ReferenceGuide?> getReferenceGuide(int id) async {
    final guide = await _referenceGuideDAO.getGuideById(id);
    if (guide == null) return null;

    if (guide.needsContentLoading && guide.pdfPath != null) {
      try {
        final content = await _pdfService.extractTextFromPdf(guide.pdfPath!);
        final updatedGuide = guide.copyWith(
          content: content,
          isPdfLoaded: true,
          updatedAt: DateTime.now(),
        );

        await _referenceGuideDAO.updateGuide(updatedGuide);
        return updatedGuide;
      } catch (e) {
        return guide.copyWith(
          content: 'Ошибка загрузки PDF: $e',
          isPdfLoaded: false,
        );
      }
    }

    return guide;
  }

  /// Обновить запись справочника
  Future<bool> updateReferenceGuide(ReferenceGuide guide) async {
    final updatedGuide = guide.copyWith(updatedAt: DateTime.now());
    final result = await _referenceGuideDAO.updateGuide(updatedGuide);
    return result > 0;
  }

  /// Удалить запись справочника
  Future<bool> deleteReferenceGuide(int id) async {
    final guide = await _referenceGuideDAO.getGuideById(id);

    // Если это PDF, удаляем файл
    if (guide?.type == ReferenceType.pdf && guide?.pdfPath != null) {
      await _pdfService.deletePdf(guide!.pdfPath!);
    }

    final result = await _referenceGuideDAO.deleteGuide(id);
    return result > 0;
  }

  /// Поиск по справочнику
  Future<List<ReferenceGuide>> searchReferenceGuides(String query) async {
    final guides = await _referenceGuideDAO.searchGuides(query);
    return await _loadPdfContentIfNeeded(guides);
  }

  /// Принудительно перезагрузить контент PDF
  Future<ReferenceGuide?> reloadPdfContent(int guideId) async {
    final guide = await _referenceGuideDAO.getGuideById(guideId);
    if (guide == null || guide.type != ReferenceType.pdf || guide.pdfPath == null) {
      return guide;
    }

    try {
      final content = await _pdfService.extractTextFromPdf(guide.pdfPath!);
      final updatedGuide = guide.copyWith(
        content: content,
        isPdfLoaded: true,
        updatedAt: DateTime.now(),
      );

      await _referenceGuideDAO.updateGuide(updatedGuide);
      return updatedGuide;
    } catch (e) {
      throw Exception('Ошибка перезагрузки PDF контента: $e');
    }
  }

  /// Получить статистику справочника
  Future<Map<String, dynamic>> getReferenceGuideStats() async {
    final guides = await _referenceGuideDAO.getAllGuides();

    final dbGuides = guides.where((g) => g.type == ReferenceType.database).length;
    final pdfGuides = guides.where((g) => g.type == ReferenceType.pdf).length;
    final loadedPdfGuides = guides.where((g) => g.type == ReferenceType.pdf && g.isPdfLoaded).length;

    return {
      'total': guides.length,
      'database': dbGuides,
      'pdf': pdfGuides,
      'pdf_loaded': loadedPdfGuides,
      'pdf_pending': pdfGuides - loadedPdfGuides,
    };
  }

  // =============================================================================
  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  // =============================================================================

  /// Загружает контент PDF для списка справочников при необходимости
  Future<List<ReferenceGuide>> _loadPdfContentIfNeeded(List<ReferenceGuide> guides) async {
    final updatedGuides = <ReferenceGuide>[];

    for (final guide in guides) {
      if (guide.needsContentLoading && guide.pdfPath != null) {
        try {
          final content = await _pdfService.extractTextFromPdf(guide.pdfPath!);
          final updatedGuide = guide.copyWith(
            content: content,
            isPdfLoaded: true,
            updatedAt: DateTime.now(),
          );

          await _referenceGuideDAO.updateGuide(updatedGuide);
          updatedGuides.add(updatedGuide);
        } catch (e) {
          updatedGuides.add(guide.copyWith(
            content: 'Ошибка загрузки PDF: $e',
            isPdfLoaded: false,
          ));
        }
      } else {
        updatedGuides.add(guide);
      }
    }

    return updatedGuides;
  }

  /// Добавить изображение к записи справочника
  Future<int> addReferenceGuideImage(int guideId, String imagePath, {String? description, int orderIndex = 0}) async {
    final image = ReferenceGuideImage(
      referenceGuideId: guideId,
      imagePath: imagePath,
      description: description,
      orderIndex: orderIndex,
      createdAt: DateTime.now(),
    );
    return await _referenceGuideDAO.insertGuideImage(image);
  }

  /// Получить изображения записи справочника
  Future<List<ReferenceGuideImage>> getReferenceGuideImages(int guideId) async {
    return await _referenceGuideDAO.getImagesByGuide(guideId);
  }

  /// Удалить изображение справочника
  Future<bool> deleteReferenceGuideImage(int id) async {
    final result = await _referenceGuideDAO.deleteGuideImage(id);
    return result > 0;
  }

  // =============================================================================
  // ИНСТРУКЦИИ ПО ЭКСПЛУАТАЦИИ
  // =============================================================================

  /// Добавить новую инструкцию по эксплуатации
  Future<int> addOperationManual(String title, String description, {String? category}) async {
    final now = DateTime.now();
    final manual = OperationManual(
      title: title,
      description: description,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
    return await _operationManualDAO.insertManual(manual);
  }

  /// Получить все инструкции по эксплуатации
  Future<List<OperationManual>> getAllOperationManuals() async {
    return await _operationManualDAO.getAllManuals();
  }

  /// Получить инструкции по эксплуатации по категории
  Future<List<OperationManual>> getOperationManualsByCategory(String category) async {
    return await _operationManualDAO.getManualsByCategory(category);
  }

  /// Получить конкретную инструкцию по эксплуатации
  Future<OperationManual?> getOperationManual(int id) async {
    return await _operationManualDAO.getManualById(id);
  }

  /// Обновить инструкцию по эксплуатации
  Future<bool> updateOperationManual(OperationManual manual) async {
    final updatedManual = manual.copyWith(updatedAt: DateTime.now());
    final result = await _operationManualDAO.updateManual(updatedManual);
    return result > 0;
  }

  /// Удалить инструкцию по эксплуатации
  Future<bool> deleteOperationManual(int id) async {
    final result = await _operationManualDAO.deleteManual(id);
    return result > 0;
  }

  /// Поиск по инструкциям
  Future<List<OperationManual>> searchOperationManuals(String query) async {
    return await _operationManualDAO.searchManuals(query);
  }

  /// Добавить изображение к инструкции
  Future<int> addOperationManualImage(int manualId, String imagePath, {String? description, int orderIndex = 0}) async {
    final image = OperationManualImage(
      operationManualId: manualId,
      imagePath: imagePath,
      description: description,
      orderIndex: orderIndex,
      createdAt: DateTime.now(),
    );
    return await _operationManualDAO.insertManualImage(image);
  }

  /// Получить изображения инструкции
  Future<List<OperationManualImage>> getOperationManualImages(int manualId) async {
    return await _operationManualDAO.getImagesByManual(manualId);
  }

  /// Удалить изображение инструкции
  Future<bool> deleteOperationManualImage(int id) async {
    final result = await _operationManualDAO.deleteManualImage(id);
    return result > 0;
  }

  // =============================================================================
  // КОМПЛЕКСНЫЕ ОПЕРАЦИИ
  // =============================================================================

  /// Получить полную информацию о пациенте (обновленная версия)
  Future<Map<String, dynamic>> getPatientSummary(String patientId) async {
    final orthopedicExaminations = await getOrthopedicExaminations(patientId);
    final densitometries = await getDensitometries(patientId);
    final motorSkills = await getMotorSkills(patientId);
    final latestSalivation = await getLatestSalivation(patientId);
    final latestGMFCS = await getGMFCS(patientId);

    return {
      'patientId': patientId,
      'orthopedicExaminations': orthopedicExaminations,
      'densitometries': densitometries,
      'motorSkills': motorSkills,
      'latestSalivation': latestSalivation,
      'latestGMFCS': latestGMFCS,
      'totalExaminations': orthopedicExaminations.length,
      'totalDensitometries': densitometries.length,
      'totalMotorSkills': motorSkills.length
    };
  }

  /// Получить полную информацию о записи справочника
  Future<Map<String, dynamic>> getReferenceGuideDetails(int guideId) async {
    final guide = await getReferenceGuide(guideId);
    if (guide == null) return {};

    final images = await getReferenceGuideImages(guideId);

    return {
      'guide': guide,
      'images': images,
      'totalImages': images.length,
    };
  }

  // Получить полную информацию об инструкции
  Future<Map<String, dynamic>> getOperationManualDetails(int manualId) async {
    final manual = await getOperationManual(manualId);
    if (manual == null) return {};

    final images = await getOperationManualImages(manualId);

    return {
      'manual': manual,
      'images': images,
      'totalImages': images.length,
    };
  }

  // Удалить все данные пациента (обновленная версия)
  Future<bool> deleteAllPatientData(String patientId) async {
    try {
      // Удаляем ортопедические осмотры (каскадно удалятся связанные данные)
      final examinations = await getOrthopedicExaminations(patientId);
      for (final exam in examinations) {
        await deleteOrthopedicExamination(exam.id!);
      }

      // Удаляем денситометрии
      final densitometries = await getDensitometries(patientId);
      for (final densitometry in densitometries) {
        await deleteDensitometry(densitometry.id!);
      }

      // Удаляем записи о слюнотечении
      final salivations = await getSalivations(patientId);
      for (final salivation in salivations) {
        await deleteSalivation(salivation.id!);
      }

      // Удаляем моторные навыки
      final motorSkills = await getMotorSkills(patientId);
      for (final skill in motorSkills) {
        await deleteMotorSkill(skill.id!);
      }

      return true;
    } catch (e) {
      return false;
    }
  }


// =============================================================================
// ДАТА РОЖДЕНИЯ ПАЦИЕНТА
// =============================================================================

  /// Установить дату рождения пациента
  Future<bool> setPatientBirthDate(String patientId, DateTime birthDate) async {
    final now = DateTime.now();
    final patientBirthDate = PatientBirthDate(
      patientId: patientId,
      birthDate: birthDate,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _patientBirthDateDAO.upsert(patientBirthDate);
    return result > 0;
  }

  /// Получить дату рождения пациента
  Future<PatientBirthDate?> getPatientBirthDate(String patientId) async {
    return await _patientBirthDateDAO.getByPatient(patientId);
  }

  /// Обновить дату рождения пациента
  Future<bool> updatePatientBirthDate(String patientId, DateTime birthDate) async {
    final existing = await getPatientBirthDate(patientId);
    if (existing == null) return false;

    final updated = existing.copyWith(
      birthDate: birthDate,
      updatedAt: DateTime.now(),
    );
    final result = await _patientBirthDateDAO.update(updated);
    return result > 0;
  }

  /// Удалить дату рождения пациента
  Future<bool> deletePatientBirthDate(String patientId) async {
    final result = await _patientBirthDateDAO.deleteByPatient(patientId);
    return result > 0;
  }


// =============================================================================
// НАПОМИНАНИЯ
// =============================================================================

  /// Создать новое напоминание
  Future<int> createReminder(
      String patientId,
      DateTime eventDateTime,
      String title,
      {String? description,
        DateTime? notifyMonthBefore,
        DateTime? notify2WeeksBefore,
        DateTime? notifyDayBefore,
        DateTime? notifyHourBefore,}
      ) async {
    final now = DateTime.now();
    final reminder = Reminder(
      patientId: patientId,
      eventDateTime: eventDateTime,
      title: title,
      description: description,
      notifyMonthBefore: notifyMonthBefore,
      notify2WeeksBefore: notify2WeeksBefore,
      notifyDayBefore: notifyDayBefore,
      notifyHourBefore: notifyHourBefore,
      createdAt: now,
      updatedAt: now,
    );
    return await _reminderDAO.insert(reminder);
  }

  /// Получить все напоминания пациента
  Future<List<Reminder>> getPatientReminders(String patientId) async {
    return await _reminderDAO.getByPatient(patientId);
  }

  /// Получить активные напоминания пациента
  Future<List<Reminder>> getActiveReminders(String patientId) async {
    return await _reminderDAO.getActiveByPatient(patientId);
  }

  /// Получить завершенные напоминания пациента
  Future<List<Reminder>> getCompletedReminders(String patientId) async {
    return await _reminderDAO.getCompletedByPatient(patientId);
  }

  /// Получить просроченные напоминания
  Future<List<Reminder>> getOverdueReminders(String patientId) async {
    return await _reminderDAO.getOverdueByPatient(patientId);
  }

  /// Получить предстоящие напоминания (на 24 часа)
  Future<List<Reminder>> getUpcomingReminders(String patientId) async {
    return await _reminderDAO.getUpcomingByPatient(patientId);
  }

  /// Получить конкретное напоминание по ID
  Future<Reminder?> getReminder(int id) async {
    return await _reminderDAO.getById(id);
  }

  /// Обновить напоминание
  Future<bool> updateReminder(Reminder reminder) async {
    final updatedReminder = reminder.copyWith(updatedAt: DateTime.now());
    final result = await _reminderDAO.update(updatedReminder);
    return result > 0;
  }

  /// Пометить напоминание как выполненное
  Future<bool> markReminderCompleted(int id) async {
    final result = await _reminderDAO.markAsCompleted(id);
    return result > 0;
  }

  /// Пометить конкретное уведомление как отправленное
  Future<bool> markSpecificNotificationSent(int id, String type) async {
    final result = await _reminderDAO.markSpecificNotificationSent(id, type);
    return result > 0;
  }

  /// Пометить уведомление как отправленное (для обратной совместимости)
  Future<bool> markNotificationSent(int id) async {
    final result = await _reminderDAO.markNotificationSent(id);
    return result > 0;
  }

  /// Удалить напоминание
  Future<bool> deleteReminder(int id) async {
    final result = await _reminderDAO.delete(id);
    return result > 0;
  }

  /// Удалить все напоминания пациента
  Future<bool> deleteAllPatientReminders(String patientId) async {
    final result = await _reminderDAO.deleteByPatient(patientId);
    return result > 0;
  }

  /// Поиск напоминаний по заголовку
  Future<List<Reminder>> searchReminders(String patientId, String query) async {
    return await _reminderDAO.searchByTitle(patientId, query);
  }

  /// Получить напоминания за период
  Future<List<Reminder>> getRemindersInDateRange(
      String patientId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    return await _reminderDAO.getByPatientAndDateRange(patientId, startDate, endDate);
  }

  /// Получить статистику напоминаний пациента
  Future<Map<String, int>> getRemindersStats(String patientId) async {
    return await _reminderDAO.getStatsByPatient(patientId);
  }

  /// Получить напоминания для отправки уведомлений
  Future<List<Reminder>> getNotificationPendingReminders() async {
    return await _reminderDAO.getNotificationPending();
  }

  /// Удалить старые завершенные напоминания
  Future<bool> cleanupOldReminders({Duration olderThan = const Duration(days: 30)}) async {
    final result = await _reminderDAO.deleteOldCompleted(olderThan);
    return result > 0;
  }
}


