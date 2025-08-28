import 'package:flutter/material.dart';

import '../../../assets/colors/app_colors.dart';
import '../../../assets/data/texts/strings.dart';
import '../../../services/database_service.dart';

class GMFCSScreen extends StatefulWidget {
  final VoidCallback onNext;
  final Function(int) onGMFCSSelected;
  final int? selectedLevel;

  const GMFCSScreen({
    Key? key,
    required this.onNext,
    required this.onGMFCSSelected,
    this.selectedLevel,
  }) : super(key: key);

  @override
  _GMFCSScreenState createState() => _GMFCSScreenState();
}

class _GMFCSScreenState extends State<GMFCSScreen> {
  int? selectedLevel;
  int? selectedOption; // Какой уровень выбрал пользователь (1-5)
  final DatabaseService _dbService = DatabaseService();
  static const String _localPatientId = '1'; // Локальный ID
  final AppStrongStrings _strings = AppStrongStrings();
  int patientAge = 0;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  void _loadPatientData() async {
    // Загружаем дату рождения пациента
    final birthDate = await _dbService.getPatientBirthDate(_localPatientId);
    if (birthDate != null) {
      final now = DateTime.now();
      final age = now.year - birthDate.birthDate.year;
      setState(() {
        patientAge = age;
      });
    }

    // Загружаем существующий GMFCS
    final gmfcs = await _dbService.getGMFCS(_localPatientId);
    if (gmfcs != null) {
      setState(() {
        selectedLevel = gmfcs.level;
        selectedOption = gmfcs.level;
      });
    }
  }

  void _selectLevel(int level) async {
    setState(() {
      selectedOption = level;
      selectedLevel = level;
    });

    // Сохраняем GMFCS в БД
    try {
      final success = await _dbService.setGMFCS(_localPatientId, level);
      if (!success) {
        print("Не удалось сохранить GMFCS в БД.");
      }
    } catch (e) {
      print("Ошибка при сохранении GMFCS: $e");
    }

    widget.onGMFCSSelected(level);
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
                  'Справка о GMFCS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'GMFCS (Gross Motor Function Classification System) - это система классификации, которая используется для оценки двигательных возможностей у детей с детским церебральным параличом (ДЦП). Она определяет пять уровней двигательных навыков, от I (наименьшие ограничения) до V (наибольшие ограничения), позволяя специалистам и родителям понять, какие двигательные функции доступны ребенку и какая помощь может потребоваться.',
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

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Уровень GMFCS',
              style: TextStyle(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
                color: AppColors.mainTitleColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Выберите описание, которое лучше всего подходит вашему ребенку (возраст: $patientAge лет)',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: AppColors.text2Color,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Генерируем 5 карточек с описаниями уровней
                    ...List.generate(5, (index) {
                      final level = index + 1;
                      final description = _strings.getLevelDescription(patientAge, 'level $level');

                      return Container(
                        margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: selectedOption == level
                                ? AppColors.primaryColor
                                : AppColors.border3Color,
                            width: selectedOption == level ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: selectedOption == level
                                  ? AppColors.primaryColor.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => _selectLevel(level),
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  margin: const EdgeInsets.only(top: 4, right: 12),
                                  decoration: BoxDecoration(
                                    color: selectedOption == level
                                        ? AppColors.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: selectedOption == level
                                          ? AppColors.primaryColor
                                          : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: selectedOption == level
                                      ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                      : null,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedOption == level
                                              ? AppColors.primaryColor
                                              : AppColors.secondryColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Уровень $level',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        description,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          height: 1.4,
                                          color: selectedOption == level
                                              ? AppColors.primaryColor
                                              : AppColors.text2Color,
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
                    }),

                    // Результат
                    if (selectedLevel != null) ...[
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: Colors.white,
                              size: screenWidth * 0.1,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            const Text(
                              'Выбранный уровень GMFCS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Уровень $selectedLevel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.08,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),

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
                // Кнопка "Далее"
                Expanded(
                  child: Container(
                    height: screenHeight * 0.07,
                    constraints: const BoxConstraints(
                      minHeight: 50,
                      maxHeight: 70,
                    ),
                    decoration: BoxDecoration(
                      gradient: selectedLevel != null
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
                        onTap: selectedLevel != null ? widget.onNext : null,
                        child: Center(
                          child: Text(
                            'Далее',
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
    );
  }
}