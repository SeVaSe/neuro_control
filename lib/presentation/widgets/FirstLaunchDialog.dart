import 'package:flutter/material.dart';
import '../../assets/colors/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchDialog extends StatelessWidget {
  final VoidCallback onLearnMorePressed;

  FirstLaunchDialog({required this.onLearnMorePressed});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Возвращаем false, чтобы предотвратить закрытие окна по кнопке "Назад"
        return false;
      },
      child: AlertDialog(
        title: Text(
          'Рекомендация',
          style: TextStyle(color: AppColors.secondryColor, fontFamily: 'TinosBold'),
        ),
        content: Text(
          'Рекомендуем вам ознакомиться с инструкцией к приложению, чтобы узнать важные особенности и нюансы. \n\nЭто находится разделе "О приложении -> Основные возможности"',
          style: TextStyle(
            color: AppColors.text2Color,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _setFirstLaunchFlag(false);
              Navigator.of(context).pop();
            },
            child: Text(
              'Знаю',
              style: TextStyle(
                color: AppColors.text1Color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _setFirstLaunchFlag(false);
              onLearnMorePressed();
            },
            child: Text(
              'Хочу узнать',
              style: TextStyle(color: AppColors.errorColor, fontFamily: 'TinosBold'),
            ),
          ),
        ],
      ),
    );
  }

  // Сохраняем флаг о первом запуске
  Future<void> _setFirstLaunchFlag(bool isFirstLaunch) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstLaunch', isFirstLaunch);
  }
}
