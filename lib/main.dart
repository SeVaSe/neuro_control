// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'presentation/basic/download_page.dart'; // Подключаем ваш DownloadPage
//
// void main() {
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   runApp(MaterialApp(
//     home: DownloadPage(), // Устанавливаем DownloadPage как главный экран
//     theme: ThemeData(
//       fontFamily: 'Tinos',  // Устанавливаем шрифт для всего приложения
//       scaffoldBackgroundColor: Colors.white,
//     ),
//   ));
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neuro_control/presentation/basic/home_screen.dart';
import 'package:neuro_control/presentation/pages/Starter/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'assets/colors/app_colors.dart';
import 'assets/data/texts/strings.dart';
import 'presentation/basic/download_page.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      theme: ThemeData(
        fontFamily: 'Tinos',
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  @override
  void initState() {
    super.initState();
    _startProgress();
    _checkFirstTime();
  }

  _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;

    await Future.delayed(Duration(seconds: 2));

    if (isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingController()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }


  void _startProgress() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.05;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          // Переход на HomeScreen
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => HomeScreen()),
          // );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.width * 0.5,
                    child: SvgPicture.asset(
                      'lib/assets/svg/down_icon.svg', // Replace with your SVG asset path
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    AppStrings.nameAppString,
                    style: TextStyle(
                      color: AppColors.thirdColor,
                      fontSize: screenWidth * 0.10, // Адаптируемый размер шрифта
                      fontFamily: 'TinosBold',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Measure the text width
                      final textPainter = TextPainter(
                        text: TextSpan(
                          text: 'NeuroOrto.Pro',
                          style: TextStyle(
                            color: AppColors.thirdColor,
                            fontSize: 31.44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        textDirection: TextDirection.ltr,
                      )..layout();

                      // Use the text width for the LinearProgressIndicator
                      final textWidth = textPainter.width;

                      return Container(
                        width: textWidth,
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 2,
                          color: AppColors.thirdColor,
                          backgroundColor: Colors.white.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

