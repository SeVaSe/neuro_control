import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:neuro_control/assets/colors/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'dart:io';

import '../../../database/entities/orthopedic_examination.dart';
import '../../../database/entities/photo_record.dart';
import '../../../services/database_service.dart';
import '../../../services/reminder_scheduler.dart';
import '../../screensTopic/topic_detail_manual.dart';

class OrtopedPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const OrtopedPage({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<OrtopedPage> createState() => _OrtopedPageState();
}

class _OrtopedPageState extends State<OrtopedPage>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<PhotoRecord> _allPhotoRecords = [];
  bool _isLoading = false;
  int? _patientAge;
  int? _gmfcsLevel;

  static const Color _primaryColor = Color(0xFF66BB6A);
  static const Color _lightColor = Color(0xFFE6FFEB);
  static const Color _yellowColor = Color(0xFFFFC107);
  static const Color _whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadPhotoRecords();
    _loadPatientData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    try {
      // Загружаем дату рождения
      final birthDateRecord = await _databaseService.getPatientBirthDate(widget.patientId);
      if (birthDateRecord != null) {
        final age = _calculateAge(birthDateRecord.birthDate);
        setState(() {
          _patientAge = age;
        });
      }

      // Загружаем GMFCS
      final gmfcsRecord = await _databaseService.getGMFCS(widget.patientId);
      if (gmfcsRecord != null) {
        setState(() {
          _gmfcsLevel = gmfcsRecord.level;
        });
      }
    } catch (e) {
      print('Ошибка загрузки данных пациента: $e');
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _loadPhotoRecords() async {
    setState(() => _isLoading = true);
    try {
      final examinations = await _databaseService
          .getOrthopedicExaminations(widget.patientId);

      List<PhotoRecord> allPhotos = [];

      for (final examination in examinations) {
        if (examination.id != null) {
          final photos =
          await _databaseService.getPhotoRecords(examination.id!);
          allPhotos.addAll(photos);
        }
      }

      allPhotos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _allPhotoRecords = allPhotos;
      });
    } catch (e) {
      _showErrorSnackBar('Ошибка загрузки данных: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Новый метод, возвращающий актуальный список (используется папкой)
  Future<List<PhotoRecord>> _fetchAllPhotoRecordsForPatient() async {
    final examinations =
    await _databaseService.getOrthopedicExaminations(widget.patientId);
    List<PhotoRecord> allPhotos = [];
    for (final examination in examinations) {
      if (examination.id != null) {
        final photos = await _databaseService.getPhotoRecords(examination.id!);
        allPhotos.addAll(photos);
      }
    }
    allPhotos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allPhotos;
  }

  // schedule теперь получает Future<void> Function()
  void _navigateToSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ExaminationSchedulePage(
          patientName: widget.patientName,
          patientAge: _patientAge,
          gmfcsLevel: _gmfcsLevel,
          onConclusionPhoto: _addConclusionPhoto,
        ),
      ),
    );
  }

  void _navigateToFolder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ExaminationFolderPage(
          photoRecords: _allPhotoRecords,
          onAddPhoto: _addConclusionPhoto,
          onDeletePhoto: _deletePhoto,
          onViewFile: _viewFile,
          fetchPhotoRecords: _fetchAllPhotoRecordsForPatient,
        ),
      ),
    ).then((_) {
      // Обновляем данные при возврате со страницы папки
      _loadPhotoRecords();
    });
  }

  Future<void> _scheduleReminder() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 0)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null) return;

    final DateTime appointmentDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    await _addToCalendar(appointmentDateTime);


    final scheduler = ReminderScheduler(_databaseService);
    await scheduler.scheduleReminder(
      patientId: widget.patientId,
      appointmentDateTime: appointmentDateTime,
      title: 'Скоро прием ортопеда',
      description: 'У вас скоро запланирован прием ортопеда. Не забудьте подготовиться к визиту!',
    );
  }


  Future<void> _addToCalendar(DateTime appointmentDateTime) async {
    try {
      final Event event = Event(
        title: 'Осмотр ортопеда - ${widget.patientName}',
        description:
        'Плановый осмотр у врача-ортопеда для ${widget.patientName}. '
            'Важно для контроля состояния опорно-двигательного аппарата.',
        location: 'Медицинский центр',
        startDate: appointmentDateTime,
        endDate: appointmentDateTime.add(const Duration(hours: 1)),
        iosParams: const IOSParams(
          reminder: Duration(minutes: 15),
          url: '',
        ),
        androidParams: const AndroidParams(
          emailInvites: [],
        ),
      );

      final success = await Add2Calendar.addEvent2Cal(event);

      if (success) {
        _showSuccessSnackBar('Напоминание добавлено в календарь');
        await _createAdditionalReminders(appointmentDateTime);
      } else {
        _showErrorSnackBar('Не удалось добавить событие в календарь');
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка при добавлении в календарь: $e');
    }
  }

  Future<void> _createAdditionalReminders(DateTime appointmentDateTime) async {
    final monthBefore = appointmentDateTime.subtract(const Duration(days: 30));
    if (monthBefore.isAfter(DateTime.now())) {
      await _addReminderEvent(
          monthBefore, 'Напоминание: через месяц осмотр ортопеда');
    }

    final dayBefore = appointmentDateTime.subtract(const Duration(days: 1));
    if (dayBefore.isAfter(DateTime.now())) {
      await _addReminderEvent(dayBefore, 'Напоминание: завтра осмотр ортопеда');
    }

    final hourBefore = appointmentDateTime.subtract(const Duration(hours: 1));
    if (hourBefore.isAfter(DateTime.now())) {
      await _addReminderEvent(hourBefore, 'Напоминание: через час осмотр ортопеда');
    }
  }

  Future<void> _addReminderEvent(DateTime dateTime, String title) async {
    final Event event = Event(
      title: title,
      description: 'Напоминание об осмотре ортопеда для ${widget.patientName}',
      startDate: dateTime,
      endDate: dateTime.add(const Duration(minutes: 15)),
    );
    await Add2Calendar.addEvent2Cal(event);
  }

  Future<void> _addConclusionPhoto() async {
    // Создаем новый осмотр для каждого заключения
    final examinationId =
    await _databaseService.createOrthopedicExamination(widget.patientId);
    await _addPhotoToExamination(examinationId);
    // Обновляем локальный список после добавления
    await _loadPhotoRecords();
  }

  Future<void> _addPhotoToExamination(int examinationId) async {
    final sourceType = await _showImageSourceDialog();
    if (sourceType == null) return;

    try {
      String? filePath;

      if (sourceType == 'camera') {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        filePath = image?.path;
      } else if (sourceType == 'gallery') {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        filePath = image?.path;
      } else if (sourceType == 'file') {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
          allowMultiple: false,
        );
        filePath = result?.files.single.path;
      }

      if (filePath != null) {
        final fileInfo = await _showFileInfoDialog();
        if (fileInfo != null) {
          await _databaseService.addPhotoRecord(
            examinationId,
            filePath,
            description:
            '${fileInfo['title']} - ${fileInfo['date']} - ${fileInfo['description']}',
          );
          await _loadPhotoRecords(); // Обновляем данные сразу
          _showSuccessSnackBar('Заключение сохранено');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка добавления файла: $e');
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    final confirmed = await _showConfirmDialog(
      'Удалить заключение?',
      'Это действие нельзя отменить',
    );

    if (confirmed) {
      try {
        await _databaseService.deletePhotoRecord(photoId);
        await _loadPhotoRecords(); // Обновляем данные сразу
        _showSuccessSnackBar('Заключение удалено');
      } catch (e) {
        _showErrorSnackBar('Ошибка удаления: $e');
      }
    }
  }

  void _viewFile(PhotoRecord photo) async {
    final file = File(photo.imagePath);

    if (!file.existsSync()) {
      _showErrorSnackBar('Файл не найден');
      return;
    }

    try {
      final result = await OpenFile.open(photo.imagePath);
      if (result.type != ResultType.done) {
        _showErrorSnackBar('Не удалось открыть файл: ${result.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка открытия файла: $e');
    }
  }

  bool _isImageFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  Future<String?> _showImageSourceDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _lightColor,
        title: const Text(
          'Выберите источник',
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSourceOption(Icons.camera_alt, 'Камера', 'camera'),
            _buildSourceOption(Icons.photo_library, 'Галерея', 'gallery'),
            _buildSourceOption(Icons.insert_drive_file, 'Файл', 'file'),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: _primaryColor),
      title: Text(title, style: const TextStyle(color: _primaryColor)),
      onTap: () => Navigator.pop(context, value),
    );
  }

  Future<Map<String, String>?> _showFileInfoDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController dateController = TextEditingController(
      text: _formatDate(DateTime.now()),
    );

    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _lightColor,
        title: const Text(
          'Информация о заключении',
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Например: Заключение ортопеда',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Дата',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _primaryColor),
                ),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  dateController.text = _formatDate(date);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                hintText: 'Дополнительная информация',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _primaryColor),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                Navigator.pop(context, {
                  'title': titleController.text.trim(),
                  'date': dateController.text,
                  'description': descriptionController.text.trim(),
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _lightColor,
        title: Text(title, style: const TextStyle(color: _primaryColor)),
        content: Text(content, style: const TextStyle(color: _primaryColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Ортопед',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () async {
              try {
                // Получаем запись по title через сервис
                final allGuides = await _databaseService.getAllReferenceGuides();
                final guide = allGuides.firstWhere(
                      (g) => g.title == 'Что такое ДЦП?',
                  orElse: () => throw Exception('Запись не найдена'),
                );

                // Переходим на экран с деталями
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TopicDetailScreen(
                      title: guide.title,
                      content: guide.content,
                      category: guide.category,
                      guideId: guide.id!,
                      referenceType: guide.type,
                      pdfPath: guide.pdfPath,
                    ),
                  ),
                );
              } catch (e) {
                // Ошибка поиска
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Не удалось открыть справочник: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],


      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 30),
              _buildActionCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _lightColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.errorColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Важная информация',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Осмотр ортопеда ребенка с ДЦП необходим для предотвращения развития ряда патологий со стороны опорно-двигательного аппарата таких, как вывих бедра, нейромышечный сколиоз, контрактуры, деформации стоп, боль, остеопороз.\n\nВ связи с этим ребенок должен быть осмотрен ортопедом согласно графику осмотров.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards() {
    return Column(
      children: [
        GestureDetector(
          onTap: _navigateToSchedule,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_view_week,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'График осмотров',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Просмотр графика и добавление заключений',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _navigateToFolder,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _yellowColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _yellowColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Папка\nосмотров',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_allPhotoRecords.length} записей',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: GestureDetector(
                onTap: _scheduleReminder,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _primaryColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.thumb_up,
                        color: _primaryColor,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Напоминание',
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Настроить\nуведомления',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Страница графика осмотров — теперь принимает Future<void> Function()
class _ExaminationSchedulePage extends StatelessWidget {
  final String patientName;
  final int? patientAge;
  final int? gmfcsLevel;
  final Future<void> Function() onConclusionPhoto;

  const _ExaminationSchedulePage({
    required this.patientName,
    required this.patientAge,
    required this.gmfcsLevel,
    required this.onConclusionPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF66BB6A),
        foregroundColor: Colors.white,
        title: const Text('График осмотров'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientInfoCard(),
            const SizedBox(height: 20),
            _buildScheduleTable(),
            const SizedBox(height: 20),
            _buildRecommendationCard(),
            const SizedBox(height: 30),
            _buildConclusionCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE6FFEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF66BB6A), width: 1),
      ),
      child: Column(
        children: [
          const Text(
            'Данные пациента',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF66BB6A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Icon(
                    Icons.cake,
                    color: Color(0xFF66BB6A),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Возраст',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    patientAge != null ? '$patientAge лет' : 'Не указан',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF66BB6A),),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.grey.shade300,
              ),
              Column(
                children: [
                  const Icon(
                    Icons.accessibility,
                    color: Color(0xFF66BB6A),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'GMFCS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    gmfcsLevel != null ? 'Уровень $gmfcsLevel' : 'Не указан',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF66BB6A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              //color: Color(0xFF66BB6A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Text(
                'График осмотров по GMFCS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const {
              0: FixedColumnWidth(80),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
              4: FlexColumnWidth(),
              5: FlexColumnWidth(),
            },
            children: [
              _buildTableHeaderRow(),
              _buildTableDataRow('2', [true, true, true, true, true], hasSpecialText: true),
              //_buildTableDataRow('2,5', [false, true, false, true, true]),
              _buildTableDataRow('3', [true, true, true, true, true], hasSpecialText: true),
              //_buildTableDataRow('3,5', [false, true, false, true, true]),
              _buildTableDataRow('4', [true, true, true, true, true], hasSpecialText: true),
              _buildTableDataRow('5', [true, true, true, true, true], hasSpecialText: true),
              _buildTableDataRow('6', [true, true, true, true, true], hasSpecialText: true),
              _buildTableDataRow('7', [true, true, true, true, true], hasSpecialText: true),
              _buildTableDataRow('8', [true, true, true, true, true], hasSpecialText: true),
              _buildTableDataRow('9', [true, true, true, true, true], hasSpecialText: true),
              _buildTableDataRow('10', [true, true, true, true, true], hasSpecialText: true),
              _buildTableDataRow('11', [true, true, true, true, true], hasSpecialText: true),
              _buildTableDataRow('12-16', [true, true, true, true, true], hasSpecialText: true),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFF42A5F5)),
      children: [
        _buildHeaderCell('Возраст'),
        _buildHeaderCell('I'),
        _buildHeaderCell('II'),
        _buildHeaderCell('III'),
        _buildHeaderCell('IV'),
        _buildHeaderCell('V'),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  TableRow _buildTableDataRow(String age, List<bool> visits, {bool hasSpecialText = false}) {
    final isCurrentAge = patientAge != null && _isAgeMatch(age, patientAge!);

    return TableRow(
      decoration: BoxDecoration(
        color: isCurrentAge ? const Color(0xFFE6FFEB) : Colors.white,
      ),
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFF42A5F5),
          ),
          child: Center(
            child: Text(
              age,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ...visits.asMap().entries.map((entry) {
          final index = entry.key;
          final shouldVisit = entry.value;
          final isPatientColumn = gmfcsLevel != null && (index + 1) == gmfcsLevel;

          return Container(
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: shouldVisit
                  ? (isPatientColumn && isCurrentAge ? const Color(0xFF3F8841) : const Color(0xFF66BB6A))
                  : (isPatientColumn && isCurrentAge ? const Color(0xFFAEE8B9) : Colors.white),
              border: isPatientColumn
                  ? Border.all(color: const Color(0xFF387E3A), width: 2)
                  : null,
            ),
            child: Center(
              child: hasSpecialText && shouldVisit && (index >= 2) // GMFCS III, IV, V для 12-16 лет
                  ? const Text(
                'x2 год',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              )
                  : (shouldVisit ? const Icon(Icons.check, color: Colors.white, size: 24) : const SizedBox()),
            ),
          );
        }).toList(),
      ],
    );
  }

  bool _isAgeMatch(String ageRange, int patientAge) {
    if (ageRange.contains('-')) {
      // Для диапазона типа "12-16"
      final parts = ageRange.split('-');
      final minAge = int.tryParse(parts[0]) ?? 0;
      final maxAge = int.tryParse(parts[1]) ?? 0;
      return patientAge >= minAge && patientAge <= maxAge;
    } else if (ageRange.contains(',')) {
      // Для возраста типа "2,5"
      final age = double.tryParse(ageRange.replaceAll(',', '.')) ?? 0;
      return patientAge == age.floor();
    } else {
      // Для целого возраста
      final age = int.tryParse(ageRange) ?? 0;
      return patientAge == age;
    }
  }

  Widget _buildRecommendationCard() {
    final recommendation = _getRecommendation();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAE0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD500), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFFFD500),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Рекомендация',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getRecommendation() {
    if (patientAge == null || gmfcsLevel == null) {
      return 'Для получения персональной рекомендации необходимо указать возраст ребенка и уровень GMFCS в профиле пациента.';
    }

    // Определяем нужность посещения на основе таблицы
    bool needsVisit = false;
    bool needsTwiceAYear = false;

    // Упрощенная логика:
    // GMFCS 1-2: один раз в год для всех возрастов
    // GMFCS 3-5: два раза в год для всех возрастов

    if (gmfcsLevel! >= 1 && gmfcsLevel! <= 2) {
      needsVisit = true;
      needsTwiceAYear = false; // один раз в год
    } else if (gmfcsLevel! >= 3 && gmfcsLevel! <= 5) {
      needsVisit = true;
      needsTwiceAYear = true; // два раза в год
    }

    if (!needsVisit) {
      return 'На данный момент плановый осмотр ортопеда не требуется согласно графику для возраста $patientAge лет и уровня GMFCS $gmfcsLevel.';
    }

    if (needsTwiceAYear) {
      return 'Рекомендуется посещать ортопеда не менее ДВУХ РАЗ В ГОД. Возраст ребенка: $patientAge лет, уровень GMFCS: $gmfcsLevel. Регулярные осмотры особенно важны для контроля прогрессирования деформаций.';
    }

    return 'Рекомендуется посещать ортопеда НЕ МЕНЕЕ ОДНОГО РАЗА В ГОД. Возраст ребенка: $patientAge лет, уровень GMFCS: $gmfcsLevel. Регулярные осмотры помогают своевременно выявить и предотвратить развитие ортопедических осложнений.';
  }

  Widget _buildConclusionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE6FFEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF66BB6A), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'Заключение ортопеда',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF66BB6A),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Сфотографируйте или загрузите заключение врача',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              // Ждём пока родитель выполнит весь процесс добавления (диалоги, сохранение)
              await onConclusionPhoto();
              // Остаёмся на странице графика — не делаем Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Заключение добавлено'), backgroundColor: Colors.green),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF66BB6A),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF66BB6A).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Добавить заключение',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Страница папки осмотров (обновляет список сразу после добавления/удаления)
class _ExaminationFolderPage extends StatefulWidget {
  final List<PhotoRecord> photoRecords;
  final Future<void> Function() onAddPhoto;
  final Future<void> Function(int) onDeletePhoto;
  final Function(PhotoRecord) onViewFile;
  final Future<List<PhotoRecord>> Function() fetchPhotoRecords;

  const _ExaminationFolderPage({
    required this.photoRecords,
    required this.onAddPhoto,
    required this.onDeletePhoto,
    required this.onViewFile,
    required this.fetchPhotoRecords,
  });

  @override
  State<_ExaminationFolderPage> createState() => _ExaminationFolderPageState();
}

class _ExaminationFolderPageState extends State<_ExaminationFolderPage> {
  static const Color _primaryColor = Color(0xFF66BB6A);
  static const Color _lightColor = Color(0xFFE6FFEB);
  static const Color _yellowColor = Color(0xFFFFC107);

  late List<PhotoRecord> _localPhotoRecords;

  @override
  void initState() {
    super.initState();
    _localPhotoRecords = widget.photoRecords;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Папка осмотров'),
        elevation: 0,
      ),
      body: _localPhotoRecords.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _localPhotoRecords.length,
        itemBuilder: (context, index) {
          final photo = _localPhotoRecords[index];
          return _buildPhotoCard(photo, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await widget.onAddPhoto();
          _localPhotoRecords = await widget.fetchPhotoRecords();
          setState(() {});
        },
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Нет записей осмотров',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте первое заключение',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await widget.onAddPhoto();
              _localPhotoRecords = await widget.fetchPhotoRecords();
              setState(() {});
            },
            icon: const Icon(Icons.add),
            label: const Text('Добавить заключение'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(PhotoRecord photo, int index) {
    final isImage = _isImageFile(photo.imagePath);
    final fileName = photo.imagePath.split('/').last;
    final fileExtension = fileName.split('.').last.toUpperCase();

    String displayTitle = 'Заключение ${index + 1}';
    String displayDate = _formatDate(photo.createdAt);
    String displayDescription = '';

    if (photo.description != null && photo.description!.contains(' - ')) {
      final parts = photo.description!.split(' - ');
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        displayTitle = parts[0];
      }
      if (parts.length > 1 && parts[1].isNotEmpty) {
        displayDate = parts[1];
      }
      if (parts.length > 2 && parts[2].isNotEmpty) {
        displayDescription = parts[2];
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => widget.onViewFile(photo),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isImage ? _lightColor : _yellowColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isImage
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(photo.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image,
                      color: Colors.grey.shade400,
                      size: 30,
                    ),
                  ),
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getFileIcon(fileExtension),
                        color: _primaryColor,
                        size: 24,
                      ),
                      Text(
                        fileExtension,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayDate,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    if (displayDescription.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        displayDescription,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isImage ? Icons.image : Icons.insert_drive_file,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isImage ? 'Изображение' : 'Документ',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'view') {
                    widget.onViewFile(photo);
                  } else if (value == 'delete') {
                    await widget.onDeletePhoto(photo.id!);
                    _localPhotoRecords = await widget.fetchPhotoRecords();
                    setState(() {});
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 18),
                        SizedBox(width: 8),
                        Text('Просмотр'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Удалить', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  bool _isImageFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}