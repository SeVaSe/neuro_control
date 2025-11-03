import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

import '../../assets/colors/app_colors.dart';
import '../../assets/data/texts/strings.dart';
import 'home_screen.dart';

class DownloadPage extends StatefulWidget {
  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.05;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          // Переход на HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
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
                    child: Image.asset(
                      'lib/assets/imgs/tree.png', // Replace with your SVG asset path
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 50),
                  buildAppNameLogo(
                    fontSize: screenWidth * 0.090,
                    fontFamily: 'TinosBold',
                  ),
                  SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Measure the text width
                      final textPainter = TextPainter(
                        text: TextSpan(
                          text: 'NeuroOrto.Control',
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
