import 'package:flutter/material.dart';
import 'package:neuro_control/assets/colors/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../database/entities/motor_skills_calendar.dart';
import '../../services/database_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';


class CalendarMotorPage extends StatefulWidget {
  const CalendarMotorPage({Key? key}) : super(key: key);

  @override
  State<CalendarMotorPage> createState() => _CalendarMotorPageState();
}

class _CalendarMotorPageState extends State<CalendarMotorPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();

  // Календарь
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<MotorSkillsCalendar>> _events = {};
  List<MotorSkillsCalendar> _selectedEvents = [];

  // Список дней
  List<DateTime> _daysWithEvents = [];

  // Константы
  static const String _patientId = "default_patient"; // Один пользователь

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null); // Импорт и инициализация русской локали
    Intl.defaultLocale = 'ru';            // Установка русской локали
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = DateTime.now();
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Загрузка событий из БД
  Future<void> _loadEvents() async {
    try {
      final skills = await _databaseService.getMotorSkills(_patientId);
      final Map<DateTime, List<MotorSkillsCalendar>> events = {};
      final Set<DateTime> daysWithEvents = {};

      for (final skill in skills) {
        final date = DateTime(
          skill.skillDate.year,
          skill.skillDate.month,
          skill.skillDate.day,
        );

        if (events[date] != null) {
          events[date]!.add(skill);
        } else {
          events[date] = [skill];
        }
        daysWithEvents.add(date);
      }

      setState(() {
        _events = events;
        _daysWithEvents = daysWithEvents.toList()
          ..sort((a, b) => b.compareTo(a)); // Сортировка по убыванию
        _selectedEvents = _getEventsForDay(_selectedDay ?? DateTime.now());
      });
    } catch (e) {
      _showErrorSnackBar('Ошибка загрузки данных: $e');
    }
  }

  List<MotorSkillsCalendar> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  // Добавление новой заметки
  Future<void> _addMotorSkill(DateTime date, String description, String? notes) async {
    try {
      await _databaseService.addMotorSkill(
        _patientId,
        date,
        description,
        notes: notes,
      );
      await _loadEvents();
      _showSuccessSnackBar('Заметка добавлена успешно');
    } catch (e) {
      _showErrorSnackBar('Ошибка добавления заметки: $e');
    }
  }

  // Обновление заметки
  Future<void> _updateMotorSkill(MotorSkillsCalendar skill) async {
    try {
      await _databaseService.updateMotorSkill(skill);
      await _loadEvents();
      _showSuccessSnackBar('Заметка обновлена успешно');
    } catch (e) {
      _showErrorSnackBar('Ошибка обновления заметки: $e');
    }
  }

  // Удаление заметки
  Future<void> _deleteMotorSkill(int id) async {
    try {
      await _databaseService.deleteMotorSkill(id);
      await _loadEvents();
      _showSuccessSnackBar('Заметка удалена успешно');
    } catch (e) {
      _showErrorSnackBar('Ошибка удаления заметки: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: AppColors.thirdColor,
        ),
        title: const Text(
          'Моторные навыки',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.thirdColor,
          indicatorWeight: 3,
          labelColor: AppColors.thirdColor,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'Календарь',
            ),
            Tab(
              icon: Icon(Icons.list),
              text: 'Список дней',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarView(),
          _buildListView(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoteDialog(),
        backgroundColor: AppColors.secondryColor,
        icon: const Icon(Icons.add, color: AppColors.thirdColor),
        label: const Text(
          'Добавить',
          style: TextStyle(
            color: AppColors.thirdColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.thirdColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TableCalendar<MotorSkillsCalendar>(
            locale: 'ru',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: AppColors.secondryColor,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: AppColors.secondryColor,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: const TextStyle(color: Color(0xFF6B7280)),
              holidayTextStyle: const TextStyle(color: Color(0xFF6B7280)),
              selectedDecoration: const BoxDecoration(
                color: AppColors.secondryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.secondryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents = _getEventsForDay(selectedDay);
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
        ),
        Expanded(
          child: _buildEventsList(_selectedEvents),
        ),
      ],
    );
  }

  Widget _buildListView() {
    if (_daysWithEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Нет записей',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте первую заметку',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _daysWithEvents.length,
      itemBuilder: (context, index) {
        final date = _daysWithEvents[index];
        final events = _getEventsForDay(date);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.thirdColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            title: Text(
              _formatDate(date),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1F2937),
              ),
            ),
            subtitle: Text(
              '${events.length} ${_getRecordWord(events.length)}',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_run,
                color: AppColors.secondryColor,
              ),
            ),
            children: events.map((event) => _buildEventTile(event)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildEventsList(List<MotorSkillsCalendar> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Нет записей на выбранную дату',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildEventTile(events[index]),
        );
      },
    );
  }

  Widget _buildEventTile(MotorSkillsCalendar event) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.thirdColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          event.skillDescription,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: event.notes != null && event.notes!.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            event.notes!,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
        )
            : null,
        trailing: PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: Color(0xFF6B7280),
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditNoteDialog(event);
                break;
              case 'delete':
                _showDeleteConfirmDialog(event);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: AppColors.secondryColor),
                  SizedBox(width: 8),
                  Text('Редактировать'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.errorColor),
                  SizedBox(width: 8),
                  Text('Удалить'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog() {
    final descriptionController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = _selectedDay ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Добавить заметку',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Дата',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      locale: const Locale('ru'), // <- добавляем это
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(_formatDate(selectedDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Описание навыка',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Введите описание навыка',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.secondryColor),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Дополнительные заметки',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    hintText: 'Дополнительная информация (необязательно)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.secondryColor),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Отмена',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (descriptionController.text.trim().isNotEmpty) {
                  _addMotorSkill(
                    selectedDate,
                    descriptionController.text.trim(),
                    notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Добавить',
                style: TextStyle(color: AppColors.thirdColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNoteDialog(MotorSkillsCalendar event) {
    final descriptionController = TextEditingController(text: event.skillDescription);
    final notesController = TextEditingController(text: event.notes ?? '');
    DateTime selectedDate = event.skillDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Редактировать заметку',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Дата',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      locale: const Locale('ru'),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(_formatDate(selectedDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Описание навыка',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Введите описание навыка',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.secondryColor),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Дополнительные заметки',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    hintText: 'Дополнительная информация (необязательно)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.secondryColor),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Отмена',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (descriptionController.text.trim().isNotEmpty) {
                  final updatedEvent = event.copyWith(
                    skillDate: selectedDate,
                    skillDescription: descriptionController.text.trim(),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                  _updateMotorSkill(updatedEvent);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Сохранить',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(MotorSkillsCalendar event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Удалить заметку',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        content: const Text(
          'Вы уверены, что хотите удалить эту заметку? Это действие нельзя отменить.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteMotorSkill(event.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Удалить',
              style: TextStyle(color: AppColors.thirdColor),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getRecordWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'запись';
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'записи';
    } else {
      return 'записей';
    }
  }
}