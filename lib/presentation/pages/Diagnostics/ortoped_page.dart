import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'dart:io';

import '../../../database/entities/orthopedic_examination.dart';
import '../../../database/entities/photo_record.dart';
import '../../../services/database_service.dart';

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

class _OrtopedPageState extends State<OrtopedPage> {
  final DatabaseService _databaseService = DatabaseService();

  List<OrthopedicExamination> _examinations = [];
  Map<int, List<PhotoRecord>> _photoRecords = {};
  bool _isLoading = false;

  static const Color _primaryColor = Color(0xFF6C63FF);
  static const Color _lightColor = Color(0xFFE8E6FF);

  @override
  void initState() {
    super.initState();
    _loadExaminations();
  }

  Future<void> _loadExaminations() async {
    setState(() => _isLoading = true);
    try {
      final examinations = await _databaseService
          .getOrthopedicExaminations(widget.patientId);

      setState(() {
        _examinations = examinations;
      });

      // Загружаем фото для каждого осмотра
      for (final examination in examinations) {
        if (examination.id != null) {
          final photos = await _databaseService
              .getPhotoRecords(examination.id!);
          setState(() {
            _photoRecords[examination.id!] = photos;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка загрузки данных: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewExamination() async {
    try {
      await _databaseService.createOrthopedicExamination(widget.patientId);
      await _loadExaminations();
      _showSuccessSnackBar('Новый осмотр создан');
    } catch (e) {
      _showErrorSnackBar('Ошибка создания осмотра: $e');
    }
  }

  Future<void> _deleteExamination(int id) async {
    final confirmed = await _showConfirmDialog(
      'Удалить осмотр?',
      'Все связанные файлы также будут удалены',
    );

    if (confirmed) {
      try {
        await _databaseService.deleteOrthopedicExamination(id);
        await _loadExaminations();
        _showSuccessSnackBar('Осмотр удален');
      } catch (e) {
        _showErrorSnackBar('Ошибка удаления: $e');
      }
    }
  }

  Future<void> _addPhotoToExamination(int examinationId) async {
    final sourceType = await _showImageSourceDialog();
    if (sourceType == null) return;

    try {
      String? filePath;

      if (sourceType == 'camera') {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.camera);
        filePath = image?.path;
      } else if (sourceType == 'gallery') {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        filePath = image?.path;
      } else if (sourceType == 'file') {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );
        filePath = result?.files.single.path;
      }

      if (filePath != null) {
        final description = await _showDescriptionDialog();
        await _databaseService.addPhotoRecord(
          examinationId,
          filePath,
          description: description?.isNotEmpty == true ? description : null,
        );
        await _loadExaminations();
        _showSuccessSnackBar('Файл добавлен');
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка добавления файла: $e');
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    final confirmed = await _showConfirmDialog(
      'Удалить файл?',
      'Это действие нельзя отменить',
    );

    if (confirmed) {
      try {
        await _databaseService.deletePhotoRecord(photoId);
        await _loadExaminations();
        _showSuccessSnackBar('Файл удален');
      } catch (e) {
        _showErrorSnackBar('Ошибка удаления файла: $e');
      }
    }
  }

  Future<void> _scheduleReminder() async {
    // Запрашиваем разрешение на доступ к календарю
    final status = await Permission.calendar.request();



    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
  }

  Future<void> _addToCalendar(DateTime appointmentDateTime) async {
    try {
      final Event event = Event(
        title: 'Прием ортопеда - ${widget.patientName}',
        description: 'Запланированный прием у врача-ортопеда для пациента ${widget.patientName}',
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
        _showSuccessSnackBar('Событие добавлено в календарь');
      } else {
        _showErrorSnackBar('Не удалось добавить событие в календарь');
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка при добавлении в календарь: $e');
    }
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
            ListTile(
              leading: const Icon(Icons.camera_alt, color: _primaryColor),
              title: const Text('Камера', style: TextStyle(color: _primaryColor)),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: _primaryColor),
              title: const Text('Галерея', style: TextStyle(color: _primaryColor)),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: _primaryColor),
              title: const Text('Файл', style: TextStyle(color: _primaryColor)),
              onTap: () => Navigator.pop(context, 'file'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showDescriptionDialog() async {
    final TextEditingController controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _lightColor,
        title: const Text(
          'Описание файла',
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Введите описание (необязательно)',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _primaryColor),
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
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

  Widget _buildPhotoGrid(List<PhotoRecord> photos, int examinationId) {
    if (photos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _lightColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _lightColor),
        ),
        child: const Column(
          children: [
            Icon(Icons.folder_open, color: Colors.grey, size: 48),
            SizedBox(height: 8),
            Text(
              'Файлы не добавлены',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return _buildPhotoItem(photo);
      },
    );
  }

  Widget _buildPhotoItem(PhotoRecord photo) {
    final file = File(photo.imagePath);
    final isImage = _isImageFile(photo.imagePath);

    return GestureDetector(
      onTap: () => _viewFile(photo),
      onLongPress: () => _deletePhoto(photo.id!),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              if (isImage && file.existsSync())
                Positioned.fill(
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: _lightColor,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  color: _lightColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getFileIcon(photo.imagePath),
                        color: _primaryColor,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          _getFileName(photo.imagePath),
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              // Индикатор описания
              if (photo.description != null && photo.description!.isNotEmpty)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isImageFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  IconData _getFileIcon(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  void _viewFile(PhotoRecord photo) async {
    final file = File(photo.imagePath);

    if (!file.existsSync()) {
      _showErrorSnackBar('Файл не найден');
      return;
    }

    if (_isImageFile(photo.imagePath)) {
      // Показываем изображение в диалоге
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
              if (photo.description != null && photo.description!.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      photo.description!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      // Пытаемся открыть файл внешним приложением
      try {
        final result = await OpenFile.open(photo.imagePath);
        if (result.type != ResultType.done) {
          _showErrorSnackBar('Не удалось открыть файл: ${result.message}');
        }
      } catch (e) {
        _showErrorSnackBar('Ошибка открытия файла: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        title: Text('Ортопед',
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
            onPressed: _scheduleReminder,
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Добавить в календарь',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : RefreshIndicator(
        color: _primaryColor,
        onRefresh: _loadExaminations,
        child: _examinations.isEmpty
            ? _buildEmptyState()
            : _buildExaminationsList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewExamination,
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _lightColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  size: 64,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Нет записей осмотров',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Нажмите + чтобы создать первый осмотр',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExaminationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _examinations.length,
      itemBuilder: (context, index) {
        final examination = _examinations[index];
        final photos = _photoRecords[examination.id] ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _lightColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.medical_services,
                color: _primaryColor,
              ),
            ),
            title: Text(
              'Прием ${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Создан: ${_formatDate(examination.createdAt)}\n'
                  'Файлов: ${photos.length}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'add_photo',
                  child: Row(
                    children: [
                      Icon(Icons.add_photo_alternate, color: _primaryColor),
                      SizedBox(width: 8),
                      Text('Добавить файл'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Удалить осмотр'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'add_photo' && examination.id != null) {
                  _addPhotoToExamination(examination.id!);
                } else if (value == 'delete' && examination.id != null) {
                  _deleteExamination(examination.id!);
                }
              },
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder_open, color: _primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Картотека заключений',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (examination.id != null)
                          IconButton(
                            onPressed: () => _addPhotoToExamination(examination.id!),
                            icon: const Icon(Icons.add, color: _primaryColor),
                            tooltip: 'Добавить файл',
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPhotoGrid(photos, examination.id ?? 0),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}