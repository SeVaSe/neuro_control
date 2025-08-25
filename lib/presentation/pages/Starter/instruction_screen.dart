import 'package:flutter/material.dart';

import '../../../assets/colors/app_colors.dart';
import '../Abouts/instruction_page.dart';

class InstructionScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const InstructionScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  _InstructionScreenState createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> {
  DateTime? instructionStartTime;
  bool hasReadInstructions = false;

  void openInstructions() {
    setState(() {
      instructionStartTime = DateTime.now();
    });

    // Навигация на экран инструкции
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OperationManualScreen(),
      ),
    ).then((_) => _checkInstructionTime());
  }



  void _checkInstructionTime() {
    if (instructionStartTime != null) {
      final elapsed = DateTime.now().difference(instructionStartTime!);

      if (elapsed.inSeconds >= 10) {
        setState(() {
          hasReadInstructions = true;
        });
      } else {
        _showWarningDialog(10 - elapsed.inSeconds);
      }
    }
  }

  void _showWarningDialog(int remainingSeconds) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: AppColors.errorColor,
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              'Внимание!',
              style: TextStyle(
                color: AppColors.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Мне кажется, вы не до конца ознакомились с инструкцией. Пожалуйста, прочтите её более внимательно!',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.text2Color,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openInstructions();
            },
            child: Text(
              'Прочитать еще раз',
              style: TextStyle(
                color: AppColors.text1Color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.menu_book,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Инструкция по использованию',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainTitleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Перед началом работы с приложением обязательно ознакомьтесь с инструкцией по использованию NeuroOrto.control',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.text2Color,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  'Это важно для правильного и безопасного использования медицинского приложения.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.text1Color,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: openInstructions,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Прочитать инструкцию',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
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
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: hasReadInstructions
                  ? LinearGradient(
                colors: [AppColors.border4Color, Color(0xFF4CAF50)],
              )
                  : LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: hasReadInstructions
                  ? [
                BoxShadow(
                  color: AppColors.border4Color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: hasReadInstructions ? widget.onComplete : null,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasReadInstructions)
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      if (hasReadInstructions) SizedBox(width: 8),
                      Text(
                        hasReadInstructions
                            ? 'Завершить настройку'
                            : 'Сначала прочитайте инструкцию',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!hasReadInstructions) ...[
            SizedBox(height: 15),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.text1Color,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Кнопка станет активной после прочтения инструкции',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.text1Color,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
