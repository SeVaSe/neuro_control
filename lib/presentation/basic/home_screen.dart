import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../assets/data/texts/strings.dart';
import '../../assets/colors/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'manual_screen.dart';
import '../widgets/FirstLaunchDialog.dart';
import 'about_screen.dart';

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
    _checkAndShowFirstLaunchDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;
          final double buttonSize = screenWidth * 0.4;
          final double buttonSpacing = screenHeight * 0.05;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                color: AppColors.thirdColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.nameAppString,
                      style: TextStyle(
                        color: AppColors.secondryColor,
                        fontFamily: 'TinosBold',
                        fontSize: screenWidth * 0.10,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: buttonSpacing),
                    // Первая строка кнопок
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton(
                          context,
                          AppStrings.buttonStartPhotoString,
                          'lib/assets/svg/calendar_exp_icon.svg',
                          buttonSize,
                          onPressed: () {
                            _showPlaceholderDialog(context, 'Календарь моторных навыков');
                          },
                        ),
                        _buildButton(
                          context,
                          AppStrings.buttonStartTreeString,
                          'lib/assets/svg/diagnostic_icon.svg',
                          buttonSize,
                          onPressed: () {
                            _showPlaceholderDialog(context, 'Диагностика');
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: buttonSpacing),
                    // Вторая строка кнопок
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton(
                          context,
                          AppStrings.buttonStartManualString,
                          'lib/assets/svg/manual_icon.svg',
                          buttonSize,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManualScreen(),
                              ),
                            );
                          },
                        ),
                        _buildOutlinedButton(
                          context,
                          AppStrings.buttonStartAboutString,
                          'lib/assets/svg/about_icon.svg',
                          buttonSize,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AboutProgram(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(
      BuildContext context,
      String title,
      String iconPath,
      double size, {
        required VoidCallback onPressed,
      }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size * 0.2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(size * 0.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: size * 0.4,
              height: size * 0.4,
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size * 0.05),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.thirdColor,
                  fontSize: size * 0.1,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
      BuildContext context,
      String title,
      String iconPath,
      double size, {
        required VoidCallback onPressed,
      }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size * 0.2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.thirdColor,
          border: Border.all(
            width: 2.0,
            color: AppColors.secondryColor,
          ),
          borderRadius: BorderRadius.circular(size * 0.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: size * 0.4,
              height: size * 0.4,
              color: AppColors.secondryColor,
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size * 0.05),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.secondryColor,
                  fontSize: size * 0.1,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Проверяем первый запуск и показываем диалог
  Future<void> _checkAndShowFirstLaunchDialog() async {
    if (_isFirstLaunchChecked) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

      if (isFirstLaunch && mounted) {
        // Отмечаем, что приложение уже было запущено
        await prefs.setBool('isFirstLaunch', false);

        // Показываем диалог после построения виджета
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showFirstLaunchDialog();
          }
        });
      }
    } catch (e) {
      debugPrint('Ошибка при проверке первого запуска: $e');
    }

    _isFirstLaunchChecked = true;
  }

  void _showFirstLaunchDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FirstLaunchDialog(
          onLearnMorePressed: () {
            Navigator.of(context).pop();
            _showPlaceholderDialog(context, 'Обучение навыкам');
          },
        );
      },
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