import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для загрузки JSON из assets
import '../../../assets/colors/app_colors.dart';
import '../../../assets/data/texts/strings.dart';
import 'autors_page.dart';
import 'instruction_page.dart';


class AboutProgram extends StatefulWidget {
  const AboutProgram({Key? key}) : super(key: key);

  @override
  _AboutProgramState createState() => _AboutProgramState();
}

class _AboutProgramState extends State<AboutProgram> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.thirdColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(
            color: AppColors.thirdColor
        ),
        title: const Text(
          AppStrings.buttonStartAboutString,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'TinosBold',
              color: AppColors.thirdColor
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Заголовок программы
            Text(
              AppStrings.nameAppString,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondryColor,
                fontSize: (screenWidth * 0.10).clamp(24.0, 40.0), // Ограничение размера
                fontFamily: 'TinosBold',
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            // Версия программы
            Text(
              AppStrings.versionString,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: (screenWidth * 0.03).clamp(12.0, 16.0),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),

            // Описание программы
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                AppStrings.textDecriptionAboutString,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.text2Color,
                  fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            // Кнопки разделов
            _buildButton(
                AppStrings.buttonAutorsAboutString,
                Icons.person,
                screenHeight,
                screenWidth,
                AuthorsScreen()
            ),
            _buildButton(
                AppStrings.buttonOsnAboutString,
                Icons.format_list_bulleted_sharp,
                screenHeight,
                screenWidth,
                OperationManualScreen()
            ),
            _buildButton(
                AppStrings.buttonStorageAboutString,
                Icons.storage,
                screenHeight,
                screenWidth,
                null, // Пока null, можно заменить на StorageScreen()
                isStorage: true
            ),
            _buildButton(
                AppStrings.buttonVideoAboutString,
                Icons.play_circle_outline,
                screenHeight,
                screenWidth,
                null, // Пока null, можно заменить на VideoWelcomeScreen()
                isVideoWelcome: true
            ),
            _buildButton(
                AppStrings.buttonOptionsAboutString,
                Icons.bubble_chart_rounded,
                screenHeight,
                screenWidth,
                null
            ),

            // Дополнительное пространство внизу для удобства прокрутки
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      String text,
      IconData icon,
      double screenHeight,
      double screenWidth,
      Widget? destinationScreen, {
        bool isVideoWelcome = false,
        bool isStorage = false,
      }) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.005,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: (screenWidth * 0.06).clamp(20.0, 28.0),
              ),
            ),
            title: Text(
              text,
              style: TextStyle(
                color: AppColors.secondryColor,
                fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.secondryColor.withOpacity(0.7),
              size: (screenWidth * 0.04).clamp(16.0, 20.0),
            ),
            onTap: () {
              if (destinationScreen != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => destinationScreen),
                );
              } else {
                String message;
                if (isVideoWelcome) {
                  message = 'Видео приветствие будет добавлено в следующих обновлениях!';
                } else if (isStorage) {
                  message = 'Хранилище будет добавлено в следующих обновлениях!';
                } else {
                  message = 'Настройки появятся в следующих обновлениях!';
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      message,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: AppColors.errorColor,
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.all(screenWidth * 0.04),
                  ),
                );
              }
            },
          ),
        ),

        // Разделитель между кнопками
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.005,
          ),
          height: 0.5,
          color: Colors.blueGrey.withOpacity(0.3),
        ),
      ],
    );
  }
}