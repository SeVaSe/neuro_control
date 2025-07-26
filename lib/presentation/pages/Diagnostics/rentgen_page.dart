import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

import '../../../database/entities/xray_image.dart';
import '../../../services/database_service.dart';

class RentgenPage extends StatefulWidget {
  final int orthopedicExaminationId;

  const RentgenPage({
    Key? key,
    required this.orthopedicExaminationId,
  }) : super(key: key);

  @override
  State<RentgenPage> createState() => _RentgenPageState();
}

class _RentgenPageState extends State<RentgenPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  List<XrayImage> _xrayImages = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFilter = 'Все';
  int _currentTabIndex = 0; // Добавляем переменную для отслеживания текущей вкладки

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Добавляем слушатель для отслеживания изменений вкладок
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });

    _loadXrayImages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadXrayImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final images = await _databaseService.getXrayImages(widget.orthopedicExaminationId);
      setState(() {
        _xrayImages = images;
      });
    } catch (e) {
      _showErrorSnackBar('Ошибка загрузки данных: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<XrayImage> get _filteredImages {
    List<XrayImage> filtered = _xrayImages;

    // Фильтрация по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((xray) {
        return xray.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      }).toList();
    }

    // Фильтрация по типу файла
    if (_selectedFilter != 'Все') {
      filtered = filtered.where((xray) {
        final extension = xray.imagePath.split('.').last.toLowerCase();
        switch (_selectedFilter) {
          case 'Изображения':
            return ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension);
          case 'PDF':
            return extension == 'pdf';
          case 'Документы':
            return ['doc', 'docx'].contains(extension);
          case 'Видео':
            return ['mp4', 'avi', 'mov'].contains(extension);
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  Future<void> _addReminderToCalendar() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B6B),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFFF6B6B),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        final DateTime reminderDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        final Event event = Event(
          title: 'Рентгенография',
          description: 'Напоминание о проведении рентгенографии',
          location: 'Медицинский центр',
          startDate: reminderDateTime,
          endDate: reminderDateTime.add(const Duration(hours: 1)),
          allDay: false,
        );

        try {
          final result = await Add2Calendar.addEvent2Cal(event);
          if (result) {
            _showSuccessSnackBar('Напоминание добавлено в календарь');
          } else {
            _showErrorSnackBar('Не удалось добавить напоминание');
          }
        } catch (e) {
          _showErrorSnackBar('Ошибка добавления напоминания: $e');
        }
      }
    }
  }

  Future<void> _addXrayFile() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFE8E8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Добавить файл',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      icon: Icons.camera_alt,
                      title: 'Камера',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromCamera();
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildOptionButton(
                      icon: Icons.photo_library,
                      title: 'Галерея',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: _buildOptionButton(
                  icon: Icons.folder,
                  title: 'Файлы',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFile();
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: const Color(0xFFFF6B6B),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      _showDescriptionDialog(image.path);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _showDescriptionDialog(image.path);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      _showDescriptionDialog(result.files.single.path!);
    }
  }

  void _showDescriptionDialog(String filePath) {
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFE8E8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Добавить описание',
            style: TextStyle(
              color: Color(0xFFFF6B6B),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Введите описание рентгена...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Отмена',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _saveXrayFile(filePath, descriptionController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Сохранить',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveXrayFile(String filePath, String description) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _databaseService.addXrayImage(
        widget.orthopedicExaminationId,
        filePath,
        description: description.isEmpty ? null : description,
      );

      _showSuccessSnackBar('Файл успешно добавлен');
      await _loadXrayImages();
    } catch (e) {
      _showErrorSnackBar('Ошибка сохранения файла: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteXrayImage(XrayImage xrayImage) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFE8E8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Удалить файл?',
            style: TextStyle(
              color: Color(0xFFFF6B6B),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('Это действие нельзя будет отменить.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Отмена',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Удалить',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && xrayImage.id != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _databaseService.deleteXrayImage(xrayImage.id!);
        if (success) {
          _showSuccessSnackBar('Файл удален');
          await _loadXrayImages();
        } else {
          _showErrorSnackBar('Не удалось удалить файл');
        }
      } catch (e) {
        _showErrorSnackBar('Ошибка удаления: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        _showErrorSnackBar('Не удалось открыть файл');
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка открытия файла: $e');
    }
  }

  // Пустой раздел графика
  Widget _buildXrayChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8E8),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 60,
              color: const Color(0xFFFF6B6B).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'График рентгенографии',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Раздел находится в разработке',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Здесь будет отображаться\nдинамика рентгенологических исследований',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Улучшенная картотека
  Widget _buildFilesList() {
    return Column(
      children: [
        // Панель поиска и фильтров
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFFFE8E8),
          child: Column(
            children: [
              // Поисковая строка
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Поиск по описанию...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFFF6B6B),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Фильтры
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Все'),
                    _buildFilterChip('Изображения'),
                    _buildFilterChip('PDF'),
                    _buildFilterChip('Документы'),
                    _buildFilterChip('Видео'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Статистика
        if (_xrayImages.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B6B).withOpacity(0.1),
                  const Color(0xFFFFE8E8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF6B6B).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.folder_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Всего файлов: ${_xrayImages.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                      Text(
                        'Найдено: ${_filteredImages.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_searchQuery.isNotEmpty || _selectedFilter != 'Все')
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedFilter = 'Все';
                      });
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: Color(0xFFFF6B6B),
                    ),
                    tooltip: 'Очистить фильтры',
                  ),
              ],
            ),
          ),
        // Список файлов
        Expanded(
          child: _filteredImages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredImages.length,
            itemBuilder: (context, index) {
              final xray = _filteredImages[index];
              return _buildFileCard(xray, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? label : 'Все';
          });
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFFF6B6B).withOpacity(0.2),
        checkmarkColor: const Color(0xFFFF6B6B),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFFFF6B6B)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_xrayImages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8E8),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.folder_open,
                size: 50,
                color: const Color(0xFFFF6B6B).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Картотека пуста',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте первый файл рентгена',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Ничего не найдено',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить параметры поиска',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFileCard(XrayImage xray, int index) {
    final fileExtension = xray.imagePath.split('.').last.toLowerCase();

    IconData fileIcon = Icons.insert_drive_file;
    Color iconColor = const Color(0xFFFF6B6B);
    String fileType = 'Файл';
    Color cardColor = Colors.white;

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileExtension)) {
      fileIcon = Icons.image;
      fileType = 'Изображение';
      cardColor = Colors.blue.shade50;
      iconColor = Colors.blue;
    } else if (['pdf'].contains(fileExtension)) {
      fileIcon = Icons.picture_as_pdf;
      fileType = 'PDF документ';
      cardColor = Colors.red.shade50;
      iconColor = Colors.red;
    } else if (['doc', 'docx'].contains(fileExtension)) {
      fileIcon = Icons.description;
      fileType = 'Документ Word';
      cardColor = Colors.indigo.shade50;
      iconColor = Colors.indigo;
    } else if (['mp4', 'avi', 'mov'].contains(fileExtension)) {
      fileIcon = Icons.videocam;
      fileType = 'Видеофайл';
      cardColor = Colors.purple.shade50;
      iconColor = Colors.purple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openFile(xray.imagePath),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Иконка файла
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconColor.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    fileIcon,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Информация о файле
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              fileType,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: iconColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (xray.description != null && xray.description!.isNotEmpty)
                        Text(
                          xray.description!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          'Без описания',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${xray.createdAt.day.toString().padLeft(2, '0')}.${xray.createdAt.month.toString().padLeft(2, '0')}.${xray.createdAt.year} в ${xray.createdAt.hour.toString().padLeft(2, '0')}:${xray.createdAt.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Кнопки действий
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _openFile(xray.imagePath),
                        icon: const Icon(
                          Icons.open_in_new,
                          color: Color(0xFFFF6B6B),
                          size: 20,
                        ),
                        tooltip: 'Открыть файл',
                        constraints: const BoxConstraints(
                          minHeight: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _deleteXrayImage(xray),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                          size: 20,
                        ),
                        tooltip: 'Удалить файл',
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B6B),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Рентгенография',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _addReminderToCalendar,
            icon: const Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
            tooltip: 'Добавить напоминание',
          ),
          // Используем _currentTabIndex вместо _tabController.index
          if (_currentTabIndex == 1)
            IconButton(
              onPressed: _addXrayFile,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              tooltip: 'Добавить файл',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics),
              text: 'График',
            ),
            Tab(
              icon: Icon(Icons.folder),
              text: 'Картотека',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Container(
        color: const Color(0xFFF8F9FA),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
              ),
              SizedBox(height: 16),
              Text(
                'Загрузка данных...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildXrayChart(),
          _buildFilesList(),
        ],
      ),
      // Используем _currentTabIndex вместо _tabController.index
      floatingActionButton: _currentTabIndex == 1
          ? FloatingActionButton.extended(
        onPressed: _addXrayFile,
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Добавить файл',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )
          : null,
    );
  }
}