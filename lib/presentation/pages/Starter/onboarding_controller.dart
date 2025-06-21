import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../assets/colors/app_colors.dart';
import '../../basic/download_page.dart';
import 'welcome_screen.dart';
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

  void nextPage() {
    if (currentPage < 2) {
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

  void completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    if (gmfcsLevel != null) {
      await prefs.setInt('gmfcs_level', gmfcsLevel!);
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
                    children: List.generate(3, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                        width: screenWidth * 0.1,
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
                    'Шаг ${currentPage + 1} из 3',
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
                WelcomeScreen(onNext: nextPage),
                GMFCSScreen(
                  onNext: nextPage,
                  onGMFCSSelected: setGMFCSLevel,
                  selectedLevel: gmfcsLevel,
                ),
                InstructionScreen(onComplete: completeOnboarding),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
