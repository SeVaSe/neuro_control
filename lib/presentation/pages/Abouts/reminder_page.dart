import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/database_service.dart';
import '../../../database/entities/reminder.dart';

class ReminderPage extends StatefulWidget {
  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> with TickerProviderStateMixin {
  static const Color primaryColor = Color(0xFF135A3E);
  static const Color secondaryColor = Color(0xff12956f);
  static const Color thirdColor = Colors.white;
  static const Color accentColor = Color(0xFF4CAF50);

  final String patientId = '1';
  final DatabaseService databaseService = DatabaseService();

  late TabController _tabController;
  List<Reminder> _allReminders = [];
  List<Reminder> _activeReminders = [];
  List<Reminder> _completedReminders = [];
  List<Reminder> _overdueReminders = [];
  List<Reminder> _upcomingReminders = [];

  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadReminders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        databaseService.getPatientReminders(patientId),
        databaseService.getActiveReminders(patientId),
        databaseService.getCompletedReminders(patientId),
        databaseService.getOverdueReminders(patientId),
        databaseService.getUpcomingReminders(patientId),
      ]);

      setState(() {
        _allReminders = results[0];
        _activeReminders = results[1];
        _completedReminders = results[2];
        _overdueReminders = results[3];
        _upcomingReminders = results[4];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Ошибка загрузки напоминаний: $e');
    }
  }

  Future<void> _searchReminders(String query) async {
    if (query.isEmpty) {
      _loadReminders();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final searchResults = await databaseService.searchReminders(patientId, query);
      setState(() {
        _allReminders = searchResults;
        _activeReminders = searchResults.where((r) => _isActive(r)).toList();
        _completedReminders = searchResults.where((r) => r.isCompleted).toList();
        _overdueReminders = searchResults.where((r) => _isOverdue(r)).toList();
        _upcomingReminders = searchResults.where((r) => _isUpcoming(r)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Ошибка поиска: $e');
    }
  }

  bool _isActive(Reminder reminder) {
    return !reminder.isCompleted && !_isOverdue(reminder);
  }

  bool _isOverdue(Reminder reminder) {
    return !reminder.isCompleted && reminder.eventDateTime.isBefore(DateTime.now());
  }

  bool _isUpcoming(Reminder reminder) {
    final now = DateTime.now();
    return !reminder.isCompleted &&
        reminder.eventDateTime.isAfter(now) &&
        reminder.eventDateTime.isBefore(now.add(Duration(hours: 24)));
  }

  Future<void> _deleteReminder(int id) async {
    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) return;

    try {
      final success = await databaseService.deleteReminder(id);
      if (success) {
        _showSuccessSnackBar('Напоминание удалено');
        _loadReminders();
      } else {
        _showErrorSnackBar('Не удалось удалить напоминание');
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка удаления: $e');
    }
  }

  Future<void> _markAsCompleted(int id) async {
    try {
      final success = await databaseService.markReminderCompleted(id);
      if (success) {
        _showSuccessSnackBar('Напоминание отмечено как выполненное');
        _loadReminders();
      } else {
        _showErrorSnackBar('Не удалось отметить напоминание');
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка обновления: $e');
    }
  }

  Future<bool> _showDeleteConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: thirdColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Удалить напоминание?',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        content: Text('Это действие нельзя отменить',
            style: TextStyle(color: Colors.grey[700])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Отмена', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Удалить', style: TextStyle(color: thirdColor)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: thirdColor),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: thirdColor),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildNotificationChip({
    required String label,
    required DateTime? notificationTime,
    required bool isSent,
    required IconData icon,
  }) {
    if (notificationTime == null) return SizedBox.shrink();

    final now = DateTime.now();
    final isPast = notificationTime.isBefore(now);

    Color backgroundColor;
    Color textColor;
    TextDecoration? decoration;

    if (isSent) {
      backgroundColor = Colors.grey[300]!;
      textColor = Colors.grey[600]!;
      decoration = TextDecoration.lineThrough;
    } else if (isPast) {
      backgroundColor = Colors.orange[100]!;
      textColor = Colors.orange[800]!;
    } else {
      backgroundColor = secondaryColor.withOpacity(0.1);
      textColor = secondaryColor;
    }

    return Container(
      margin: EdgeInsets.only(right: 6, bottom: 4),
      child: Chip(
        avatar: Icon(icon, size: 14, color: textColor),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            decoration: decoration,
          ),
        ),
        backgroundColor: backgroundColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildNotificationsSection(Reminder reminder) {
    final notifications = <Widget>[];

    // Добавляем чипы для каждого типа уведомления
    if (reminder.notifyMonthBefore != null) {
      notifications.add(_buildNotificationChip(
        label: '1 мес',
        notificationTime: reminder.notifyMonthBefore,
        isSent: reminder.isMonthSent ?? false,
        icon: Icons.calendar_month,
      ));
    }

    if (reminder.notify2WeeksBefore != null) {
      notifications.add(_buildNotificationChip(
        label: '2 нед',
        notificationTime: reminder.notify2WeeksBefore,
        isSent: reminder.is2WeeksSent ?? false,
        icon: Icons.date_range,
      ));
    }

    if (reminder.notifyDayBefore != null) {
      notifications.add(_buildNotificationChip(
        label: '1 день',
        notificationTime: reminder.notifyDayBefore,
        isSent: reminder.isDaySent ?? false,
        icon: Icons.today,
      ));
    }

    if (reminder.notifyHourBefore != null) {
      notifications.add(_buildNotificationChip(
        label: '1 час',
        notificationTime: reminder.notifyHourBefore,
        isSent: reminder.isHourSent ?? false,
        icon: Icons.schedule,
      ));
    }

    if (notifications.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'Уведомления:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4),
        Wrap(
          children: notifications,
        ),
      ],
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      color: thirdColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reminder.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                _buildStatusChip(reminder),
              ],
            ),
            const SizedBox(height: 8),

            if (reminder.description != null && reminder.description!.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  reminder.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.event, size: 16, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Событие: ${DateFormat('dd.MM.yyyy HH:mm').format(reminder.eventDateTime)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            _buildNotificationsSection(reminder),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Создано: ${DateFormat('dd.MM.yyyy').format(reminder.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!reminder.isCompleted) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.check_circle_outline, color: thirdColor, size: 20),
                          onPressed: () => _markAsCompleted(reminder.id!),
                          tooltip: 'Отметить как выполненное',
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete_outline, color: thirdColor, size: 20),
                        onPressed: () => _deleteReminder(reminder.id!),
                        tooltip: 'Удалить',
                        padding: EdgeInsets.all(8),
                        constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Reminder reminder) {
    Color color;
    String label;
    IconData icon;

    if (reminder.isCompleted) {
      color = accentColor;
      label = 'Выполнено';
      icon = Icons.check_circle;
    } else if (_isOverdue(reminder)) {
      color = Colors.red;
      label = 'Просрочено';
      icon = Icons.warning;
    } else if (_isUpcoming(reminder)) {
      color = Colors.orange;
      label = 'Скоро';
      icon = Icons.schedule;
    } else {
      color = secondaryColor;
      label = 'Активно';
      icon = Icons.notifications_active;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: thirdColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: thirdColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList(List<Reminder> reminders) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: secondaryColor, strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              'Загрузка напоминаний...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_note, size: 48, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              'Напоминания не найдены',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Здесь будут отображаться ваши напоминания',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: secondaryColor,
      backgroundColor: thirdColor,
      onRefresh: _loadReminders,
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          return _buildReminderCard(reminders[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: thirdColor,
        elevation: 0,
        title: const Text(
          'Напоминания',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: thirdColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: primaryColor),
                      decoration: InputDecoration(
                        hintText: 'Поиск напоминаний...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: primaryColor),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, color: primaryColor),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _loadReminders();
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: thirdColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _searchReminders(value);
                      },
                    ),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: thirdColor,
                  indicatorWeight: 3,
                  labelColor: thirdColor,
                  unselectedLabelColor: thirdColor.withOpacity(0.7),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
                  isScrollable: true,
                  tabs: [
                    Tab(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.list, size: 18),
                          SizedBox(height: 2),
                          Text('Все (${_allReminders.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_active, size: 18),
                          SizedBox(height: 2),
                          Text('Активные (${_activeReminders.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 18),
                          SizedBox(height: 2),
                          Text('Скоро (${_upcomingReminders.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 18),
                          SizedBox(height: 2),
                          Text('Выполненные (${_completedReminders.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 18),
                          SizedBox(height: 2),
                          Text('Просроченные (${_overdueReminders.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemindersList(_allReminders),
          _buildRemindersList(_activeReminders),
          _buildRemindersList(_upcomingReminders),
          _buildRemindersList(_completedReminders),
          _buildRemindersList(_overdueReminders),
        ],
      ),
    );
  }
}