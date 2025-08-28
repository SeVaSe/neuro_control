import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для загрузки JSON из assets
import '../../assets/colors/app_colors.dart';
import '../../assets/data/texts/strings.dart';
import '../pages/Abouts/autors_page.dart';
import '../pages/Abouts/birth_date_reload_page.dart';
import '../pages/Abouts/gmfcs_reload_page.dart';
import '../pages/Abouts/instruction_page.dart';
import '../pages/Abouts/video_hello_page.dart';

class AboutProgram extends StatefulWidget {
  const AboutProgram({Key? key}) : super(key: key);

  @override
  _AboutProgramState createState() => _AboutProgramState();
}

class _AboutProgramState extends State<AboutProgram> {
  // Контроллер прокрутки для NestedScrollView, аналогично ManualScreen
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose(); // Обязательно освобождаем контроллер
    super.dispose();
  }

  // Метод для показа диалога подтверждения изменения даты рождения
  void _showBirthDateConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isTablet = screenWidth > 600;

        return AlertDialog(
          backgroundColor: AppColors.thirdColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.errorColor,
                size: isTablet ? 28.0 : 24.0,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Подтверждение изменения даты',
                  style: TextStyle(
                    color: AppColors.secondryColor,
                    fontSize: isTablet ? 20.0 : 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'TinosBold',
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Если вы измените дату рождения, это может повлиять на текущие данные пациента.',
                style: TextStyle(
                  color: AppColors.text2Color,
                  fontSize: isTablet ? 16.0 : 14.0,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Вы точно хотите продолжить?',
                style: TextStyle(
                  color: AppColors.secondryColor,
                  fontSize: isTablet ? 16.0 : 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20.0 : 16.0,
                  vertical: isTablet ? 12.0 : 10.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Отмена',
                style: TextStyle(
                  color: AppColors.text2Color,
                  fontSize: isTablet ? 16.0 : 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BirthDateReloadPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.thirdColor,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20.0 : 16.0,
                  vertical: isTablet ? 12.0 : 10.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: Text(
                'Продолжить',
                style: TextStyle(
                  fontSize: isTablet ? 16.0 : 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Метод для показа диалога подтверждения изменения GMFCS
  void _showGMFCSConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Пользователь должен выбрать опцию
      builder: (BuildContext context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isTablet = screenWidth > 600;

        return AlertDialog(
          backgroundColor: AppColors.thirdColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.errorColor,
                size: isTablet ? 28.0 : 24.0,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Подтверждение изменения',
                  style: TextStyle(
                    color: AppColors.secondryColor,
                    fontSize: isTablet ? 20.0 : 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'TinosBold',
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Если вы измените уровень GMFCS, текущий уровень будет изменен на новый.',
                style: TextStyle(
                  color: AppColors.text2Color,
                  fontSize: isTablet ? 16.0 : 14.0,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Вы точно хотите продолжить?',
                style: TextStyle(
                  color: AppColors.secondryColor,
                  fontSize: isTablet ? 16.0 : 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            // Кнопка "Отмена"
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20.0 : 16.0,
                  vertical: isTablet ? 12.0 : 10.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Отмена',
                style: TextStyle(
                  color: AppColors.text2Color,
                  fontSize: isTablet ? 16.0 : 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Кнопка "Продолжить"
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
                // Переходим к экрану изменения GMFCS
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GMFCSUpdateScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.thirdColor,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20.0 : 16.0,
                  vertical: isTablet ? 12.0 : 10.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: Text(
                'Продолжить',
                style: TextStyle(
                  fontSize: isTablet ? 16.0 : 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    // Определяем, является ли устройство планшетом для адаптивного дизайна
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      // Устанавливаем фоновый цвет Scaffold в соответствии с ManualScreen
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: AppColors.primaryColor, // Основной цвет AppBar
              iconTheme: const IconThemeData(color: AppColors.thirdColor), // Цвет иконок
              title: const Text(
                AppStrings.buttonStartAboutString, // Заголовок "О программе"
                style: TextStyle(
                  fontFamily: 'TinosBold', // Шрифт
                  fontWeight: FontWeight.bold,
                  color: AppColors.thirdColor, // Цвет текста
                ),
              ),
              elevation: 0, // Убираем тень
              pinned: true, // AppBar остается видимым при прокрутке
              floating: false,
              snap: false,
              expandedHeight: 130, // Уменьшаем высоту, так как описание перенесено
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent, // Прозрачный статус-бар
                statusBarIconBrightness: Brightness.light, // Светлые иконки в статус-баре
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(color: AppColors.primaryColor),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 0), // Отступы
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end, // Выравнивание текста снизу
                        crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание по левому краю
                        children: [
                          // // Название программы
                          // Text(
                          //   AppStrings.nameAppString,
                          //   textAlign: TextAlign.left,
                          //   style: TextStyle(
                          //     color: AppColors.thirdColor, // Цвет текста
                          //     fontSize: isTablet ? 36.0 : 28.0, // Адаптивный размер шрифта
                          //     fontFamily: 'TinosBold',
                          //     fontWeight: FontWeight.w800,
                          //   ),
                          // ),
                          // SizedBox(height: isTablet ? 8 : 4),
                          //
                          // // Версия программы
                          // Padding(
                          //   padding: const EdgeInsets.only(bottom: 16),
                          //   child: Text(
                          //     AppStrings.versionString,
                          //     textAlign: TextAlign.left,
                          //     style: TextStyle(
                          //       color: AppColors.thirdColor.withOpacity(0.7), // Немного приглушенный цвет
                          //       fontSize: isTablet ? 16.0 : 14.0, // Адаптивный размер шрифта
                          //       fontWeight: FontWeight.w400,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Добавляем закругление внизу AppBar
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Container(
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        // Основное содержимое NestedScrollView
        body: SingleChildScrollView( // Убираем Stack и используем только SingleChildScrollView
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Название программы
              Text(
                AppStrings.nameAppString,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.secondryColor, // Цвет текста
                  fontSize: isTablet ? 36.0 : 28.0, // Адаптивный размер шрифта
                  fontFamily: 'TinosBold',
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: isTablet ? 8 : 4),

              // Версия программы
              Padding(
                padding: const EdgeInsets.only(bottom: 32), // Увеличил отступ снизу с 16 до 32
                child: Text(
                  AppStrings.versionString,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.secondryColor.withOpacity(0.7), // Немного приглушенный цвет
                    fontSize: isTablet ? 16.0 : 14.0, // Адаптивный размер шрифта
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              // Описание программы (перенесено сюда)
              Container(
                padding: EdgeInsets.all(isTablet ? 20.0 : 16.0), // Адаптивные отступы
                decoration: BoxDecoration(
                  color: AppColors.thirdColor, // Белый цвет фона, как у TextField в ManualScreen
                  borderRadius: BorderRadius.circular(15), // Закругленные углы
                  border: Border.all(
                    color: Colors.grey[300]!, // Легкая рамка
                    width: 1.5,
                  ),
                ),
                margin: EdgeInsets.only(bottom: screenHeight * 0.04), // Отступ снизу
                child: Text(
                  AppStrings.textDecriptionAboutString,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.text2Color, // Цвет текста
                    fontSize: (screenWidth * 0.04).clamp(14.0, 18.0), // Адаптивный размер шрифта
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),

              // Кнопки разделов (логика кнопок не изменена)
              _buildButton(
                  AppStrings.buttonAutorsAboutString,
                  Icons.person,
                  screenHeight,
                  screenWidth,
                  AuthorsScreen()),
              _buildButton(
                  AppStrings.buttonOsnAboutString,
                  Icons.format_list_bulleted_sharp,
                  screenHeight,
                  screenWidth,
                  OperationManualScreen()),
              _buildButton(
                  AppStrings.buttonGMFCSAboutString,
                  Icons.published_with_changes,
                  screenHeight,
                  screenWidth,
                  null, // Передаем null, так как теперь используем специальную логику
                  isGMFCS: true),
              _buildButton(
                  "Поменять дату рождения",
                  Icons.update,
                  screenHeight,
                  screenWidth,
                  BirthDateReloadPage(),
                  isBirthDate: true),
              _buildButton(
                  AppStrings.buttonVideoAboutString,
                  Icons.play_circle_outline,
                  screenHeight,
                  screenWidth,
                  VideoHelloPage(),
              ),
              // ,
              // _buildButton(
              //     AppStrings.buttonOptionsAboutString,
              //     Icons.bubble_chart_rounded,
              //     screenHeight,
              //     screenWidth,
              //     null),

              // Дополнительное пространство внизу для удобства прокрутки
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
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
        bool isGMFCS = false,
        bool isBirthDate = false, // новый флаг
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
              if (isGMFCS) {
                _showGMFCSConfirmationDialog();
              } else if (isBirthDate) {
                _showBirthDateConfirmationDialog(); // показываем предупреждение для даты
              } else if (destinationScreen != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => destinationScreen),
                );
              } else {
                String message = isVideoWelcome
                    ? 'Видео приветствие будет добавлено в следующих обновлениях!'
                    : 'Настройки появятся в следующих обновлениях!';
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