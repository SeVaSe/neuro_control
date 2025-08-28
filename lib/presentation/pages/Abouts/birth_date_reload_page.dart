import 'package:flutter/material.dart';
import '../../../assets/colors/app_colors.dart';
import '../../../services/database_service.dart';

class BirthDateReloadPage extends StatefulWidget {
  const BirthDateReloadPage({Key? key}) : super(key: key);

  @override
  _BirthDateReloadPageState createState() => _BirthDateReloadPageState();
}

class _BirthDateReloadPageState extends State<BirthDateReloadPage> {
  DateTime? selectedDate;
  DateTime? currentBirthDate;
  final DatabaseService _dbService = DatabaseService();
  static const String _localPatientId = '1'; // Локальный ID
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentBirthDate();
  }

  void _loadCurrentBirthDate() async {
    try {
      final birthDateData = await _dbService.getPatientBirthDate(_localPatientId);
      setState(() {
        if (birthDateData != null) {
          currentBirthDate = birthDateData.birthDate;
          selectedDate = birthDateData.birthDate;
        }
        isLoading = false;
      });
    } catch (e) {
      print("Ошибка при загрузке даты рождения: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().subtract(Duration(days: 365 * 10)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ru', 'RU'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
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

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor.withOpacity(0.1),
                  AppColors.secondryColor.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'О дате рождения',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Дата рождения используется для точного расчета возраста пациента, что критически важно для правильной оценки развития и подбора подходящих методов терапии. Возраст влияет на интерпретацию результатов различных тестов и шкал оценки. Система автоматически обновляет возраст вашего ребенка по мере того, как ему исполняется год, поэтому вам не придется вручную изменять эту информацию каждый раз.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Понятно',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.thirdColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Изменение даты рождения',
          style: TextStyle(
            color: AppColors.thirdColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'TinosBold',
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Дата рождения',
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainTitleColor,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Выберите правильную дату рождения пациента',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: AppColors.text2Color,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Текущая дата рождения
              if (currentBirthDate != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.border3Color,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Текущая дата рождения:',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: AppColors.text2Color,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        _formatDate(currentBirthDate!),
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text1Color,
                        ),
                      ),
                      Text(
                        'Возраст: ${_calculateAge(currentBirthDate!)} лет',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: AppColors.text2Color,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
              ],

              // Выбор новой даты
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: selectedDate != null
                        ? AppColors.primaryColor
                        : AppColors.border3Color,
                    width: selectedDate != null ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selectedDate != null
                          ? AppColors.primaryColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calendar_today,
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
                                selectedDate != null
                                    ? 'Новая дата рождения:'
                                    : 'Выберите дату рождения',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: AppColors.text2Color,
                                ),
                              ),
                              if (selectedDate != null) ...[
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  _formatDate(selectedDate!),
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                Text(
                                  'Возраст: ${_calculateAge(selectedDate!)} лет',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: AppColors.text2Color,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.primaryColor,
                          size: screenWidth * 0.04,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Кнопки внизу
              Row(
                children: [
                  // Кнопка с иконкой вопроса
                  Container(
                    width: screenHeight * 0.07,
                    height: screenHeight * 0.07,
                    constraints: const BoxConstraints(
                      minWidth: 50,
                      minHeight: 50,
                      maxWidth: 70,
                      maxHeight: 70,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(35),
                        onTap: _showInfoDialog,
                        child: Center(
                          child: Icon(
                            Icons.help_outline,
                            color: AppColors.primaryColor,
                            size: screenWidth * 0.06,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  // Кнопка "Изменить"
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.07,
                      constraints: const BoxConstraints(
                        minHeight: 50,
                        maxHeight: 70,
                      ),
                      decoration: BoxDecoration(
                        gradient: (selectedDate != null && selectedDate != currentBirthDate)
                            ? AppColors.primaryGradient
                            : LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade500],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: (selectedDate != null && selectedDate != currentBirthDate)
                              ? () async {
                            if (selectedDate == null) return;

                            try {
                              bool success;
                              if (currentBirthDate != null) {
                                // Обновляем существующую дату
                                success = await _dbService.updatePatientBirthDate(_localPatientId, selectedDate!);
                              } else {
                                // Создаем новую запись
                                success = await _dbService.setPatientBirthDate(_localPatientId, selectedDate!);
                              }

                              if (!success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Не удалось сохранить дату рождения')),
                                );
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Дата рождения обновлена')),
                              );

                              Navigator.pop(context); // вернуться назад
                            } catch (e) {
                              print("Ошибка при сохранении даты рождения: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ошибка сохранения даты рождения')),
                              );
                            }
                          }
                              : null,
                          child: Center(
                            child: Text(
                              'Изменить',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}