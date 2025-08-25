import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../assets/colors/app_colors.dart';
import '../../../services/database_service.dart';

class BirthDateScreen extends StatefulWidget {
  final VoidCallback onNext;
  final Function(DateTime) onBirthDateSelected;
  final DateTime? selectedBirthDate;
  final String patientId; // Добавляем patientId

  const BirthDateScreen({
    Key? key,
    required this.onNext,
    required this.onBirthDateSelected,
    required this.patientId, // Обязательный параметр
    this.selectedBirthDate,
  }) : super(key: key);

  @override
  _BirthDateScreenState createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime? _selectedDate;
  bool _showDatePicker = false;
  bool _isLoading = false;
  bool _isSaving = false;

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedBirthDate;
    _initializeAnimations();
    _loadBirthDate();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  // Загружаем дату рождения из БД при инициализации
  Future<void> _loadBirthDate() async {
    if (widget.selectedBirthDate != null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final patientBirthDate = await _databaseService.getPatientBirthDate(widget.patientId);
      if (patientBirthDate != null) {
        setState(() {
          _selectedDate = patientBirthDate.birthDate;
        });
        widget.onBirthDateSelected(patientBirthDate.birthDate);
      }
    } catch (e) {
      print('Ошибка загрузки даты рождения: $e');
      _showErrorSnackBar('Ошибка загрузки данных');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;

    if (months < 0) {
      years--;
      months += 12;
    } else if (months == 0 && now.day < birthDate.day) {
      years--;
      months = 11;
    } else if (now.day < birthDate.day) {
      months--;
    }

    if (years == 0) {
      return '$months мес.';
    } else if (months == 0) {
      return '$years ${_getYearWord(years)}';
    } else {
      return '$years ${_getYearWord(years)} $months мес.';
    }
  }

  String _getYearWord(int years) {
    if (years % 10 == 1 && years % 100 != 11) {
      return 'год';
    } else if ([2, 3, 4].contains(years % 10) && ![12, 13, 14].contains(years % 100)) {
      return 'года';
    } else {
      return 'лет';
    }
  }

  void _selectDate() {
    setState(() {
      _showDatePicker = true;
    });
  }

  // Сохраняем дату в БД при изменении
  Future<void> _onDateChanged(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _isSaving = true;
    });

    try {
      final success = await _databaseService.setPatientBirthDate(widget.patientId, date);

      if (success) {
        widget.onBirthDateSelected(date);
      } else {
        _showErrorSnackBar('Ошибка сохранения данных');
      }
    } catch (e) {
      print('Ошибка сохранения даты рождения: $e');
      _showErrorSnackBar('Ошибка сохранения данных');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _hideDatePicker() {
    setState(() {
      _showDatePicker = false;
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildDateSelector(double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: _isLoading || _isSaving ? null : _selectDate,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.025,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedDate != null
                ? AppColors.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isLoading || _isSaving
                  ? SizedBox(
                width: screenWidth * 0.06,
                height: screenWidth * 0.06,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              )
                  : Icon(
                Icons.cake_outlined,
                color: AppColors.primaryColor,
                size: screenWidth * 0.06,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLoading
                        ? 'Загрузка...'
                        : _selectedDate != null
                        ? _formatDate(_selectedDate!)
                        : 'Выберите дату рождения',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                      color: _selectedDate != null
                          ? AppColors.text1Color
                          : Colors.grey[600],
                    ),
                  ),
                  if (_selectedDate != null && !_isLoading) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Возраст: ${_calculateAge(_selectedDate!)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.038,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_isSaving) ...[
                          SizedBox(width: 8),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: screenWidth * 0.04,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(double screenWidth, double screenHeight) {
    return Container(
      height: screenHeight * 0.35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : _hideDatePicker,
                  child: Text(
                    'Отмена',
                    style: TextStyle(
                      color: _isSaving ? Colors.grey[400] : Colors.grey[600],
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Дата рождения',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text1Color,
                      ),
                    ),
                    if (_isSaving) ...[
                      SizedBox(width: 8),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ],
                ),
                TextButton(
                  onPressed: _isSaving ? null : _hideDatePicker,
                  child: Text(
                    'Готово',
                    style: TextStyle(
                      color: _isSaving ? Colors.grey[400] : AppColors.primaryColor,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _selectedDate ?? DateTime(DateTime.now().year - 5),
              minimumDate: DateTime(DateTime.now().year - 18),
              maximumDate: DateTime.now(),
              onDateTimeChanged: _isSaving ? (date) {} : _onDateChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) => FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Иконка
                              Container(
                                width: screenWidth * 0.25,
                                height: screenWidth * 0.25,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.child_friendly,
                                  size: screenWidth * 0.12,
                                  color: Colors.white,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.04),

                              // Заголовок
                              Text(
                                'Дата рождения ребенка',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.075,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mainTitleColor,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: screenHeight * 0.025),

                              // Описание
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                child: Text(
                                  'Укажите дату рождения вашего ребенка. Эта информация поможет нам лучше адаптировать рекомендации и следить за развитием.',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.042,
                                    color: AppColors.text2Color,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.04),

                              // Селектор даты
                              _buildDateSelector(screenWidth, screenHeight),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Кнопка "Продолжить"
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.07,
                    constraints: BoxConstraints(minHeight: 50, maxHeight: 70),
                    decoration: BoxDecoration(
                      gradient: _selectedDate != null && !_isLoading && !_isSaving
                          ? AppColors.primaryGradient
                          : LinearGradient(colors: [Colors.grey, Colors.grey]),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: _selectedDate != null && !_isLoading && !_isSaving ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ] : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: _selectedDate != null && !_isLoading && !_isSaving
                            ? widget.onNext
                            : null,
                        child: Center(
                          child: _isLoading || _isSaving
                              ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Продолжить',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: screenWidth * 0.05,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Оверлей для DatePicker
            if (_showDatePicker)
              GestureDetector(
                onTap: _isSaving ? null : _hideDatePicker,
                child: Container(
                  color: Colors.black54,
                ),
              ),

            // DatePicker
            if (_showDatePicker)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildDatePicker(screenWidth, screenHeight),
              ),
          ],
        ),
      ),
    );
  }
}