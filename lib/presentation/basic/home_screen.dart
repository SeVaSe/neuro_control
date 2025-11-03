import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../assets/colors/app_colors.dart';
import '../../assets/data/texts/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'calendar_motor.dart';
import 'manual_screen.dart';
import 'about_screen.dart';
import 'menu_diagnostics.dart';
import '../../../services/database_service.dart';
import '../../../database/entities/reminder.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isFirstLaunchChecked = false;
  Timer? _reminderCheckTimer;
  final String patientId = '1';
  final DatabaseService databaseService = DatabaseService();

  // Для предотвращения множественных показов одного уведомления
  final Set<String> _currentlyShownNotifications = <String>{};

  String get _patientId => patientId;

  @override
  void initState() {
    super.initState();
    _startReminderChecking();
  }

  @override
  void dispose() {
    _reminderCheckTimer?.cancel();
    super.dispose();
  }

  // Запуск периодической проверки напоминаний
  void _startReminderChecking() {
    // Проверяем напоминания каждые 30 секунд
    _reminderCheckTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _checkForUpcomingReminders();
    });

    // Первоначальная проверка через 2 секунды
    Future.delayed(Duration(seconds: 2), () {
      _checkForUpcomingReminders();
    });
  }

  // Проверка предстоящих напоминаний с системой этапов уведомлений
  Future<void> _checkForUpcomingReminders() async {
    if (!mounted) return;

    try {
      // Получаем все активные напоминания пациента
      final activeReminders = await databaseService.getActiveReminders(_patientId);

      for (final reminder in activeReminders) {
        if (reminder.isCompleted) continue;

        // Проверяем каждый тип уведомления
        await _checkNotification(reminder, 'month', reminder.notifyMonthBefore);
        await _checkNotification(reminder, '2weeks', reminder.notify2WeeksBefore);
        await _checkNotification(reminder, 'day', reminder.notifyDayBefore);
        await _checkNotification(reminder, 'hour', reminder.notifyHourBefore);
      }
    } catch (e) {
      debugPrint('Ошибка при проверке напоминаний: $e');
    }
  }

  // Проверка конкретного уведомления
  Future<void> _checkNotification(Reminder reminder, String type, DateTime? notificationTime) async {
    if (!mounted || notificationTime == null) return;

    final now = DateTime.now();
    final notificationKey = '${reminder.id}_$type';

    // Проверяем, не показывается ли уже это уведомление
    if (_currentlyShownNotifications.contains(notificationKey)) return;

    // Проверяем, пришло ли время для уведомления (с допуском в 1 минуту)
    if (notificationTime.isBefore(now) || notificationTime.difference(now).abs() < Duration(minutes: 1)) {

      // Проверяем, было ли уже отправлено это уведомление
      final wasNotificationSent = _wasNotificationSent(reminder, type);

      if (!wasNotificationSent) {
        _currentlyShownNotifications.add(notificationKey);
        _showReminderNotification(reminder, type, notificationTime);
      }
    }
  }

  // Проверяем, было ли отправлено уведомление определенного типа
  bool _wasNotificationSent(Reminder reminder, String type) {
    switch (type) {
      case 'month':
        return reminder.isMonthSent ?? false;
      case '2weeks':
        return reminder.is2WeeksSent ?? false;
      case 'day':
        return reminder.isDaySent ?? false;
      case 'hour':
        return reminder.isHourSent ?? false;
      default:
        return false;
    }
  }

  // Получаем данные для уведомления в зависимости от типа
  Map<String, dynamic> _getNotificationData(String type) {
    switch (type) {
      case 'month':
        return {
          'text': 'Напоминание за месяц',
          'color': Colors.blue,
          'icon': Icons.calendar_month,
          'description': 'До события остался месяц',
        };
      case '2weeks':
        return {
          'text': 'Напоминание за две недели',
          'color': Colors.green,
          'icon': Icons.calendar_view_week,
          'description': 'До события осталось две недели',
        };
      case 'day':
        return {
          'text': 'Напоминание за день',
          'color': Colors.orange,
          'icon': Icons.calendar_today,
          'description': 'До события остался день',
        };
      case 'hour':
        return {
          'text': 'Последнее напоминание!',
          'color': Colors.red,
          'icon': Icons.access_alarm,
          'description': 'До события остался час',
        };
      default:
        return {
          'text': 'Напоминание',
          'color': Colors.grey,
          'icon': Icons.notifications,
          'description': 'Напоминание о событии',
        };
    }
  }

  // Показ уведомления о напоминании
  void _showReminderNotification(Reminder reminder, String type, DateTime notificationTime) {
    if (!mounted) return;

    final notificationData = _getNotificationData(type);
    final isLastNotification = type == 'hour';
    final notificationKey = '${reminder.id}_$type';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 16,
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: AppColors.thirdColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Заголовок с иконкой
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            notificationData['color'].withOpacity(0.1),
                            notificationData['color'].withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: notificationData['color'].withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              notificationData['icon'],
                              color: notificationData['color'],
                              size: 32,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Напоминание',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: notificationData['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              notificationData['text'],
                              style: TextStyle(
                                color: notificationData['color'],
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Контент
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Основная информация о напоминании
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.secondryColor.withOpacity(0.05),
                                  AppColors.primaryColor.withOpacity(0.03),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.secondryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),

                                if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                                  SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.thirdColor.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      reminder.description!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],

                                SizedBox(height: 16),

                                // Время события
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondryColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.event,
                                          size: 18,
                                          color: AppColors.secondryColor,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Время события',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              _formatEventTime(reminder.eventDateTime),
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.secondryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Предупреждение для последнего уведомления
                          if (isLastNotification) ...[
                            SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.withOpacity(0.05),
                                    Colors.orange.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Последнее напоминание!',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Выберите действие для завершения напоминания',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Кнопки действий
                    Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: isLastNotification
                          ? _buildLastNotificationActions(reminder, type, notificationKey)
                          : _buildRegularNotificationActions(reminder, type, notificationKey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Кнопки для обычных уведомлений
  Widget _buildRegularNotificationActions(Reminder reminder, String type, String notificationKey) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondryColor,
          foregroundColor: AppColors.thirdColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
          elevation: 2,
        ),
        onPressed: () => _handleNotificationAction(reminder, type, notificationKey, false),
        icon: Icon(Icons.check, size: 22, color: Colors.white,),
        label: Text(
          'Понятно',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Кнопки для последнего уведомления
  Widget _buildLastNotificationActions(Reminder reminder, String type, String notificationKey) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: AppColors.thirdColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
                onPressed: () => _handleNotificationAction(reminder, type, notificationKey, false),
                label: Text(
                  'Пропустить',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondryColor,
                  foregroundColor: AppColors.thirdColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
                onPressed: () => _handleNotificationAction(reminder, type, notificationKey, true),
                label: Text(
                  'Выполню',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Обработка действий с уведомлением
  Future<void> _handleNotificationAction(Reminder reminder, String type, String notificationKey, bool markAsCompleted) async {
    if (!mounted) return;

    Navigator.of(context).pop();
    _currentlyShownNotifications.remove(notificationKey);

    try {
      // Отмечаем уведомление как отправленное
      final notificationSuccess = await databaseService.markSpecificNotificationSent(reminder.id!, type);

      if (notificationSuccess) {
        debugPrint('Уведомление $type для напоминания ${reminder.id} отмечено как отправленное');

        // Если нужно отметить как выполненное
        if (markAsCompleted) {
          final completionSuccess = await databaseService.markReminderCompleted(reminder.id!);
          if (completionSuccess) {
            _showSuccessSnackBar('Напоминание отмечено как выполненное');
          } else {
            _showErrorSnackBar('Не удалось отметить напоминание как выполненное');
          }
        } else {
          _showSuccessSnackBar('Уведомление принято');
        }
      } else {
        _showErrorSnackBar('Ошибка при обработке уведомления');
      }
    } catch (e) {
      debugPrint('Ошибка при обработке уведомления: $e');
      _showErrorSnackBar('Произошла ошибка при обработке уведомления');
    }
  }

  // Форматирование времени события
  String _formatEventTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (eventDate == today) {
      dateStr = 'Сегодня';
    } else if (eventDate == today.add(Duration(days: 1))) {
      dateStr = 'Завтра';
    } else if (eventDate == today.subtract(Duration(days: 1))) {
      dateStr = 'Вчера';
    } else {
      final difference = eventDate.difference(today).inDays;
      if (difference > 0 && difference <= 7) {
        dateStr = 'Через $difference ${_getDaysWord(difference)}';
      } else if (difference < 0 && difference >= -7) {
        dateStr = '${difference.abs()} ${_getDaysWord(difference.abs())} назад';
      } else {
        dateStr = DateFormat('dd.MM.yyyy').format(dateTime);
      }
    }

    final timeStr = DateFormat('HH:mm').format(dateTime);
    return '$dateStr в $timeStr';
  }

  String _getDaysWord(int days) {
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }

  // Показ сообщений пользователю
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.thirdColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: AppColors.thirdColor,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.secondryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.thirdColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.thirdColor,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
        elevation: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;
            final double smallButtonSize = screenWidth * 0.22;
            final double rectangleHeight = screenHeight * 0.22;

            return Container(
              width: double.infinity,
              height: double.infinity,
              color: AppColors.thirdColor,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    children: [
                      // Заголовок приложения
                      Container(
                        margin: EdgeInsets.only(
                          top: screenHeight * 0.02,
                          bottom: screenHeight * 0.04,
                        ),
                        child: buildAppName(
                          fontSize: screenWidth * 0.075,
                          fontFamily: 'TinosBold',
                        ),
                      ),

                      // Секция "Родительский контроль"
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: screenHeight * 0.03),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Заголовок секции
                            Container(
                              margin: EdgeInsets.only(
                                left: screenWidth * 0.02,
                                bottom: screenHeight * 0.02,
                              ),
                            ),

                            // Маленькие кнопки
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSmallButton(
                                    context,
                                    'О программе',
                                    Icons.info_outline,
                                    smallButtonSize,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AboutProgram(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.04),
                                Expanded(
                                  child: _buildSmallButton(
                                    context,
                                    'Справочник',
                                    Icons.menu_book_outlined,
                                    smallButtonSize,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ManualScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Основные функции
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Заголовок основных функций
                            Container(
                              margin: EdgeInsets.only(
                                left: screenWidth * 0.02,
                                bottom: screenHeight * 0.025,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondryColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Text(
                                    'Родительский контроль',
                                    style: TextStyle(
                                      color: AppColors.secondryColor,
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Прямоугольник "Диагностика"
                            Container(
                              margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                              child: _buildRectangleButton(
                                context,
                                'Диагностика',
                                'lib/assets/svg/tree_icon.svg',
                                rectangleHeight,
                                isDiagnostics: true,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MenuPage(),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Прямоугольник "Календарь навыков"
                            _buildRectangleButton(
                              context,
                              'Календарь навыков',
                              'lib/assets/svg/calendar_exp_icon.svg',
                              rectangleHeight,
                              isDiagnostics: false,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CalendarMotorPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Отступ снизу
                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSmallButton(
      BuildContext context,
      String title,
      IconData icon,
      double size, {
        required VoidCallback onPressed,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.secondryColor.withOpacity(0.1),
        highlightColor: AppColors.secondryColor.withOpacity(0.05),
        child: Container(
          height: size,
          decoration: BoxDecoration(
            color: AppColors.thirdColor,
            border: Border.all(
              width: 1.5,
              color: AppColors.secondryColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: size * 0.25,
                color: AppColors.secondryColor,
              ),
              SizedBox(height: size * 0.06),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size * 0.06),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondryColor,
                    fontSize: size * 0.12,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRectangleButton(
      BuildContext context,
      String title,
      String iconPath,
      double height, {
        required bool isDiagnostics,
        required VoidCallback onPressed,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: isDiagnostics
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF8C00),
                const Color(0xFFFF7F00),
                const Color(0xFFFF6B00),
              ],
              stops: const [0.0, 0.5, 1.0],
            )
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDiagnostics
                    ? const Color(0xFFFF8C00).withOpacity(0.3)
                    : Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Декоративные элементы
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Основной контент
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: AppColors.thirdColor,
                              fontSize: screenWidth * 0.058,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.thirdColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: SvgPicture.asset(
                          iconPath,
                          width: height * 0.35,
                          height: height * 0.35,
                          color: AppColors.thirdColor.withOpacity(0.9),
                          fit: BoxFit.contain,
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
}