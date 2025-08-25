import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../assets/colors/app_colors.dart';
import '../../basic/download_page.dart';
import 'welcome_screen.dart';
import 'birth_date_screen.dart';
import 'gmfcs_screen.dart';
import 'instruction_screen.dart';

class OnboardingController extends StatefulWidget {
  @override
  _OnboardingControllerState createState() => _OnboardingControllerState();
}

class _OnboardingControllerState extends State<OnboardingController> {
  PageController pageController = PageController();
  int currentPage = 0;
  int? gmfcsLevel;
  DateTime? birthDate;

  // final DatabaseService _databaseService = DatabaseService();

  void nextPage() {
    if (currentPage < 3) { // Изменено с 2 на 3 (теперь 4 страницы: 0,1,2,3)
      setState(() {
        currentPage++;
      });
      pageController.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void setGMFCSLevel(int level) {
    setState(() {
      gmfcsLevel = level;
    });
  }

  void setBirthDate(DateTime date) {
    setState(() {
      birthDate = date;
    });
  }

  void completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);

    // Сохраняем GMFCS уровень
    if (gmfcsLevel != null) {
      await prefs.setInt('gmfcs_level', gmfcsLevel!);
    }

    // Сохраняем дату рождения в SharedPreferences для резерва
    if (birthDate != null) {
      await prefs.setString('birth_date', birthDate!.toIso8601String());

    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DownloadPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          // Progress indicator
          Container(
            height: screenHeight * 0.12, // 12% от высоты экрана
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.015),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) { // Изменено с 3 на 4
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.008), // Уменьшено для 4 элементов
                        width: screenWidth * 0.08, // Уменьшено для 4 элементов
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= currentPage
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Шаг ${currentPage + 1} из 4', // Изменено с "из 3" на "из 4"
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Page content
          Expanded(
            child: PageView(
              controller: pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                // Шаг 1: Добро пожаловать
                WelcomeScreen(onNext: nextPage),

                // Шаг 2: Дата рождения ребенка
                BirthDateScreen(
                  onNext: nextPage,
                  onBirthDateSelected: setBirthDate,
                  selectedBirthDate: birthDate, patientId: '1',
                ),

                // Шаг 3: GMFCS уровень
                GMFCSScreen(
                  onNext: nextPage,
                  onGMFCSSelected: setGMFCSLevel,
                  selectedLevel: gmfcsLevel,
                ),

                // Шаг 4: Инструкции
                InstructionScreen(onComplete: completeOnboarding),
              ],
            ),
          ),
        ],
      ),
    );
  }
}