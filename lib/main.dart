import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'presentation/basic/download_page.dart'; // Подключаем ваш DownloadPage

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MaterialApp(
    home: DownloadPage(), // Устанавливаем DownloadPage как главный экран
    theme: ThemeData(
      fontFamily: 'Tinos',  // Устанавливаем шрифт для всего приложения
      scaffoldBackgroundColor: Colors.white,
    ),
  ));
}
