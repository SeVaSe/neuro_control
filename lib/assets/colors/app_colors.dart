import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета
  static const Color primaryColor = Color(0xFF158f1a); // глубокий синий
  static const Color secondryColor = Color(0xff45b54b); // яркий синий
  // static const Color primaryColor = Color(0xFF135A3E); // глубокий синий
  // static const Color secondryColor = Color(0xff12956f); // яркий синий
  static const Color thirdColor = Colors.white; // белый

  // Цвета текстов
  static const Color mainTitleColor = secondryColor; // заголовки
  static const Color text1Color = Color(0xff2d9c95); // голубой для акцентов
  static const Color text2Color = Color(0xFF10756D); // насыщенный синий

  // Цвета ошибок/предупреждений
  static const Color errorColor = Color(0xFFD32F2F); // насыщенный красный

  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [secondryColor, primaryColor],
  ); // Основной градиент

  static const LinearGradient textGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
  ); // Градиент для текста

  // Бордеры
  static const Color border1Color = Color(0xFF1976D2);
  static const Color border2Color = Color(0xFF64B5F6);
  static const Color border3Color = Color(0xFF90CAF9);
  static const Color border4Color = Color(0xFF0DA14D);

  // Прогресс бар
  static const Color progressFill1Color = Color(0x801E88E5);
  static const Color progressFill2Color = Color(0xFF1E88E5);
  static const Color progressBorderColor = Color(0xFF64B5F6);
}
