import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../assets/colors/app_colors.dart';
import '../../assets/data/texts/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar_motor.dart';
import 'manual_screen.dart';
import 'about_screen.dart';
import 'menu_diagnostics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isFirstLaunchChecked = false;

  @override
  void initState() {
    super.initState();
    //_checkAndShowFirstLaunchDialog();
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
                        child: Text(
                          AppStrings.nameAppString,
                          style: TextStyle(
                            color: AppColors.secondryColor,
                            fontFamily: 'TinosBold',
                            fontSize: screenWidth * 0.075,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
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
                size: size * 0.25, // Немного уменьшил иконку
                color: AppColors.secondryColor,
              ),
              SizedBox(height: size * 0.06), // Уменьшил отступ
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size * 0.06), // Уменьшил отступы
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondryColor,
                    fontSize: size * 0.12, // Увеличил с 0.09 до 0.12
                    fontWeight: FontWeight.w700, // Увеличил жирность с w600 до w700
                    height: 1.0, // Уменьшил высоту строки
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

  // Заглушка для переходов на другие экраны
  void _showPlaceholderDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(feature),
          content: Text('Этот раздел находится в разработке'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}