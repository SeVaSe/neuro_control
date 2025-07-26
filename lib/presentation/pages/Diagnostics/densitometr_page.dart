import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../../../database/entities/densitometry.dart';
import '../../../database/entities/gmfcs.dart';
import '../../../services/database_service.dart';

class DensitometrPage extends StatefulWidget {
  final String patientId;

  const DensitometrPage({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  State<DensitometrPage> createState() => _DensitometrPageState();
}

class _DensitometrPageState extends State<DensitometrPage> {
  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();

  GMFCS? _gmfcs;
  List<Densitometry> _densitometries = [];
  bool _isLoading = true;
  bool _isUploading = false;

  static const Color primaryColor = Color(0xFF4ECDC4);
  static const Color lightColor = Color(0xFFE8FFFD);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        _showAddDescriptionDialog(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка при съемке: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        _showAddDescriptionDialog(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка при выборе изображения: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        _showAddDescriptionDialog(result.files.single.path!);
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка при выборе файла: $e');
    }
  }

  void _showAddDescriptionDialog(String filePath) {
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Добавить описание',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildFilePreview(filePath),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Описание (необязательно)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveDensitometry(filePath, _descriptionController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Сохранить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(filePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFileIcon(extension),
        ),
      );
    } else {
      return _buildFileIcon(extension);
    }
  }

  Widget _buildFileIcon(String extension) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileIcon(extension),
            size: 48,
            color: primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            extension.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _saveDensitometry(String filePath, String description) async {
    setState(() => _isUploading = true);

    try {
      await _databaseService.addDensitometry(
        widget.patientId,
        filePath,
        description: description.isEmpty ? null : description,
      );

      _showSuccessSnackBar('Файл успешно сохранен');
      await _loadData();
    } catch (e) {
      _showErrorSnackBar('Ошибка сохранения: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteDensitometry(Densitometry densitometry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Подтверждение удаления',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Вы уверены, что хотите удалить этот файл из картотеки?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Отмена',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.deleteDensitometry(densitometry.id!);
        _showSuccessSnackBar('Файл удален из картотеки');
        await _loadData();
      } catch (e) {
        _showErrorSnackBar('Ошибка удаления: $e');
      }
    }
  }

  void _showFileOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Добавить файл в картотеку',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.camera_alt,
              title: 'Сфотографировать',
              subtitle: 'Сделать снимок камерой',
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            _buildOptionTile(
              icon: Icons.photo_library,
              title: 'Выбрать из галереи',
              subtitle: 'Выбрать изображение',
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            _buildOptionTile(
              icon: Icons.attach_file,
              title: 'Выбрать файл',
              subtitle: 'PDF, DOC, изображения',
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: lightColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey.shade50,
      ),
    );
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
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: primaryColor),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGMFCSCard(),
              const SizedBox(height: 20),
              _buildRecommendationCard(),
              if (_needsDensitometry) ...[
                const SizedBox(height: 20),
                _buildFileSection(),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: _needsDensitometry
          ? FloatingActionButton.extended(
        onPressed: _isUploading ? null : _showFileOptions,
        backgroundColor: primaryColor,
        icon: _isUploading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Добавить',
          style: TextStyle(color: Colors.white),
        ),
      )
          : null,
    );
  }

  Widget _buildGMFCSCard() {
    return Card(
      elevation: 3,
      shadowColor: primaryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lightColor, Colors.white],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assessment,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Уровень GMFCS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_gmfcs != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _needsDensitometry
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _needsDensitometry ? Colors.orange : Colors.green,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _needsDensitometry ? Icons.warning : Icons.check_circle,
                      color: _needsDensitometry ? Colors.orange : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Уровень ${_gmfcs!.level}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _needsDensitometry ? Colors.orange[700] : Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    const Text(
                      'Уровень GMFCS не определен',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    if (!_needsDensitometry) {
      return Card(
        elevation: 3,
        shadowColor: Colors.green.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.green.withOpacity(0.1),
                Colors.green.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Денситометрия не требуется',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Клиническое заключение:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'При текущем уровне функциональной классификации GMFCS (${_gmfcs?.level ?? 'не определен'}) проведение денситометрического исследования не показано. Минеральная плотность костной ткани соответствует возрастной норме для данной категории пациентов.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      shadowColor: Colors.orange.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.1),
              Colors.orange.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_services,
                size: 48,
                color: Colors.orange[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Рекомендована денситометрия',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Медицинское показание:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Пациенту с уровнем GMFCS ${_gmfcs?.level} показано проведение денситометрического исследования для оценки минеральной плотности костной ткани и раннего выявления остеопенических изменений.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSection() {
    return Card(
      elevation: 3,
      shadowColor: primaryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.folder_open,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Картотека денситометрии',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_densitometries.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_densitometries.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2), style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Картотека пуста',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Добавьте результаты денситометрического исследования для ведения медицинской документации',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _densitometries.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final densitometry = _densitometries[index];
                  return _buildDensitometryItem(densitometry);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDensitometryItem(Densitometry densitometry) {
    final extension = densitometry.imagePath.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png'].contains(extension);
    final fileName = densitometry.imagePath.split('/').last;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: lightColor,
          ),
          child: isImage
              ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(densitometry.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildFileIcon(extension),
            ),
          )
              : _buildFileIcon(extension),
        ),
        title: Text(
          fileName,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (densitometry.description != null && densitometry.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                densitometry.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd.MM.yyyy в HH:mm').format(densitometry.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'open',
              child: Row(
                children: [
                  Icon(Icons.open_in_new, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text('Открыть'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  const Text('Просмотр'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  const Text('Удалить'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'open') {
              _openFileExternally(densitometry);
            } else if (value == 'view') {
              _showFilePreview(densitometry);
            } else if (value == 'delete') {
              _deleteDensitometry(densitometry);
            }
          },
        ),
        onTap: () => _openFileExternally(densitometry),
      ),
    );
  }

  void _showFilePreview(Densitometry densitometry) {
    final extension = densitometry.imagePath.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png'].contains(extension);
    final fileName = densitometry.imagePath.split('/').last;

    if (isImage) {
      // Для изображений показываем в диалоге
      _showImageDialog(densitometry, fileName);
    } else {
      // Для других файлов открываем во внешнем приложении
      _openFileExternally(densitometry);
    }
  }

  void _showImageDialog(Densitometry densitometry, String fileName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        _openFileExternally(densitometry);
                      },
                      tooltip: 'Открыть во внешнем приложении',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(densitometry.imagePath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorWidget('Ошибка загрузки изображения'),
                    ),
                  ),
                ),
              ),

              // Description and date
              if (densitometry.description != null && densitometry.description!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: lightColor.withOpacity(0.5),
                    border: Border(
                      top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Описание:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        densitometry.description!,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),

              // Footer with date and open button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Добавлено: ${DateFormat('dd.MM.yyyy в HH:mm').format(densitometry.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openFileExternally(densitometry);
                      },
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Открыть'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFileExternally(Densitometry densitometry) async {
    try {
      final file = File(densitometry.imagePath);

      // Проверяем, существует ли файл
      if (!await file.exists()) {
        _showErrorSnackBar('Файл не найден: ${densitometry.imagePath}');
        return;
      }

      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );

      // Открываем файл
      final result = await OpenFile.open(densitometry.imagePath);

      // Закрываем индикатор загрузки
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Обрабатываем результат
      if (result.type != ResultType.done) {
        String errorMessage;
        switch (result.type) {
          case ResultType.noAppToOpen:
            errorMessage = 'Нет приложения для открытия этого типа файлов';
            break;
          case ResultType.fileNotFound:
            errorMessage = 'Файл не найден';
            break;
          case ResultType.permissionDenied:
            errorMessage = 'Нет разрешения на открытие файла';
            break;
          default:
            errorMessage = 'Не удалось открыть файл: ${result.message}';
        }
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      // Закрываем индикатор загрузки в случае ошибки
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorSnackBar('Ошибка при открытии файла: $e');
    }
  }

  Widget _buildFilePreviewWidget(String extension, String fileName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: lightColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getFileIcon(extension),
              size: 64,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            fileName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              extension.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Файл сохранен в картотеке',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}