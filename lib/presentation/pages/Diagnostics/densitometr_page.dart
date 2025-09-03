import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../../../database/entities/densitometry.dart';
import '../../../database/entities/gmfcs.dart';
import '../../../services/database_service.dart';
import '../../screensTopic/topic_detail_manual.dart';

class DensitometrPage extends StatefulWidget {
  final String patientId;

  const DensitometrPage({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  State<DensitometrPage> createState() => _DensitometrPageState();
}

class _DensitometrPageState extends State<DensitometrPage>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _imagePicker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  GMFCS? _gmfcs;
  List<Densitometry> _densitometries = [];
  bool _isLoading = true;
  bool _isUploading = false;

  static const Color primaryColor = Color(0xFF26A66C);
  static const Color lightColor = Color(0xFFE8FFF4);
  static const Color yellowColor = Color(0xFFFFC107);

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
    _loadData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final gmfcs = await _databaseService.getGMFCS(widget.patientId);
      final densitometries = await _databaseService.getDensitometries(widget.patientId);

      setState(() {
        _gmfcs = gmfcs;
        _densitometries = densitometries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Ошибка загрузки данных: $e');
    }
  }

  bool get _needsDensitometry => _gmfcs?.level != null && _gmfcs!.level >= 4;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  Future<void> _addDensitometryFile() async {
    final sourceType = await _showImageSourceDialog();
    if (sourceType == null) return;

    try {
      String? filePath;

      if (sourceType == 'camera') {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        filePath = image?.path;
      } else if (sourceType == 'gallery') {
        final XFile? image = await _imagePicker.pickImage(
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
          setState(() => _isUploading = true);

          await _databaseService.addDensitometry(
            widget.patientId,
            filePath,
            description: '${fileInfo['title']} - ${fileInfo['date']} - ${fileInfo['description']}',
          );

          await _loadData();
          _showSuccessSnackBar('Заключение денситометрии сохранено');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка добавления файла: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<String?> _showImageSourceDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightColor,
        title: const Text(
          'Выберите источник',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
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
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: const TextStyle(color: primaryColor)),
      onTap: () => Navigator.pop(context, value),
    );
  }

  Future<Map<String, String>?> _showFileInfoDialog() async {
    final TextEditingController titleController = TextEditingController(
      text: 'Заключение денситометрии',
    );
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController dateController = TextEditingController(
      text: _formatDate(DateTime.now()),
    );

    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightColor,
        title: const Text(
          'Информация о заключении',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Например: Заключение денситометрии',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
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
                  borderSide: BorderSide(color: primaryColor),
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
                  borderSide: BorderSide(color: primaryColor),
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
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDensitometry(Densitometry densitometry) async {
    final confirmed = await _showConfirmDialog(
      'Удалить заключение?',
      'Это действие нельзя отменить',
    );

    if (confirmed) {
      try {
        await _databaseService.deleteDensitometry(densitometry.id!);
        await _loadData();
        _showSuccessSnackBar('Заключение удалено');
      } catch (e) {
        _showErrorSnackBar('Ошибка удаления: $e');
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightColor,
        title: Text(title, style: const TextStyle(color: primaryColor)),
        content: Text(content, style: const TextStyle(color: primaryColor)),
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

  void _navigateToFolder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _DensitometryFolderPage(
          densitometries: _densitometries,
          onAddFile: _addDensitometryFile,
          onDeleteFile: _deleteDensitometry,
          onViewFile: _viewFile,
          fetchDensitometries: () async {
            return await _databaseService.getDensitometries(widget.patientId);
          },
        ),
      ),
    ).then((_) {
      _loadData();
    });
  }

  void _viewFile(Densitometry densitometry) async {
    final file = File(densitometry.imagePath);

    if (!file.existsSync()) {
      _showErrorSnackBar('Файл не найден');
      return;
    }

    try {
      final result = await OpenFile.open(densitometry.imagePath);
      if (result.type != ResultType.done) {
        _showErrorSnackBar('Не удалось открыть файл: ${result.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка открытия файла: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Денситометрия',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                      (g) => g.title == 'Что такое денситометрия?',
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
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: primaryColor),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecommendationCard(),
              if (_needsDensitometry) ...[
                const SizedBox(height: 20),
                _buildActionCards(),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    final level = _gmfcs?.level ?? 0;
    final needsDensitometry = level >= 4;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: needsDensitometry ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: needsDensitometry ? Colors.orange : Colors.green,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: needsDensitometry ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              needsDensitometry ? Icons.medical_services : Icons.check_circle,
              size: 48,
              color: needsDensitometry ? Colors.orange[600] : Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            needsDensitometry
                ? 'Необходимо проведение денситометрии, начиная с 5 лет, раз в 2 года'
                : 'Не нужно проводить, учитывая, что у вашего ребенка $level уровень',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: needsDensitometry ? Colors.orange[700] : Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: needsDensitometry ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3),
              ),
            ),
            child: Text(
              needsDensitometry
                  ? 'При уровне GMFCS $level рекомендуется регулярное проведение денситометрии для контроля минеральной плотности костной ткани и профилактики остеопороза.'
                  : 'При уровне GMFCS $level риск развития остеопороза минимален, поэтому специальные исследования костной плотности не требуются.',
              style: TextStyle(
                fontSize: 14,
                color: needsDensitometry ? Colors.orange[600] : Colors.green[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _isUploading ? null : _addDensitometryFile,
            child: _buildCard(
              isUploading: _isUploading,
              icon: Icons.add_a_photo,
              title: _isUploading ? 'Сохранение...' : 'Добавить заключение',
              subtitle: 'Загрузить файл',
              color: primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: _navigateToFolder,
            child: _buildCard(
              isUploading: false,
              icon: Icons.folder,
              title: 'Папка денситометрии',
              subtitle: '${_densitometries.length} записей',
              color: yellowColor,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildCard({
    required bool isUploading,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    IconData? trailingIcon,
  }) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isUploading)
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            else
              Icon(
                icon,
                color: Colors.white,
                size: 36,
              ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (trailingIcon != null) ...[
              const Spacer(),
              Icon(
                trailingIcon,
                color: Colors.white,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Страница папки денситометрии
class _DensitometryFolderPage extends StatefulWidget {
  final List<Densitometry> densitometries;
  final Future<void> Function() onAddFile;
  final Future<void> Function(Densitometry) onDeleteFile;
  final Function(Densitometry) onViewFile;
  final Future<List<Densitometry>> Function() fetchDensitometries;

  const _DensitometryFolderPage({
    required this.densitometries,
    required this.onAddFile,
    required this.onDeleteFile,
    required this.onViewFile,
    required this.fetchDensitometries,
  });

  @override
  State<_DensitometryFolderPage> createState() => _DensitometryFolderPageState();
}

class _DensitometryFolderPageState extends State<_DensitometryFolderPage> {
  static const Color primaryColor = Color(0xFF26A66C);
  static const Color lightColor = Color(0xFFE8FFF4);
  static const Color yellowColor = Color(0xFFFFC107);

  late List<Densitometry> _localDensitometries;

  @override
  void initState() {
    super.initState();
    _localDensitometries = widget.densitometries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Папка денситометрии'),
        elevation: 0,
      ),
      body: _localDensitometries.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _localDensitometries.length,
        itemBuilder: (context, index) {
          final densitometry = _localDensitometries[index];
          return _buildDensitometryCard(densitometry, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await widget.onAddFile();
          _localDensitometries = await widget.fetchDensitometries();
          setState(() {});
        },
        backgroundColor: primaryColor,
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
            'Нет заключений денситометрии',
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
              await widget.onAddFile();
              _localDensitometries = await widget.fetchDensitometries();
              setState(() {});
            },
            icon: const Icon(Icons.add),
            label: const Text('Добавить заключение'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDensitometryCard(Densitometry densitometry, int index) {
    final isImage = _isImageFile(densitometry.imagePath);
    final fileName = densitometry.imagePath.split('/').last;
    final fileExtension = fileName.split('.').last.toUpperCase();

    String displayTitle = 'Заключение денситометрии ${index + 1}';
    String displayDate = DateFormat('dd.MM.yyyy').format(densitometry.createdAt);
    String displayDescription = '';

    if (densitometry.description != null && densitometry.description!.contains(' - ')) {
      final parts = densitometry.description!.split(' - ');
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
        onTap: () => widget.onViewFile(densitometry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isImage ? lightColor : yellowColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isImage
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(densitometry.imagePath),
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
                        color: primaryColor,
                        size: 24,
                      ),
                      Text(
                        fileExtension,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
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
                    if (displayDescription.isNotEmpty) ...[const SizedBox(height: 4),
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
                    widget.onViewFile(densitometry);
                  } else if (value == 'delete') {
                    await widget.onDeleteFile(densitometry);
                    _localDensitometries = await widget.fetchDensitometries();
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
}