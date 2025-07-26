import 'package:flutter/material.dart';
import '../../../assets/colors/app_colors.dart';
import '../../../services/database_service.dart';

class GMFCSUpdateScreen extends StatefulWidget {
  const GMFCSUpdateScreen({Key? key}) : super(key: key);

  @override
  _GMFCSUpdateScreenState createState() => _GMFCSUpdateScreenState();
}

class _GMFCSUpdateScreenState extends State<GMFCSUpdateScreen> {
  int? selectedLevel;
  Map<String, bool> answers = {};
  final _dbService = DatabaseService();
  static const _localPatientId = '1'; // локальный ID

  @override
  void initState() {
    super.initState();
    _loadExistingGMFCS();
  }

  void _loadExistingGMFCS() async {
    final gmfs = await _dbService.getGMFCS(_localPatientId);
    if (gmfs != null) {
      setState(() {
        selectedLevel = gmfs.level;
      });
    }
  }


  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Может ли пациент ходить без ограничений?',
    },
    {
      'question': 'Может ли пациент ходить без вспомогательных средств?',
    },
    {
      'question': 'Может ли пациент подниматься по лестнице с перилами?',
    },
    {
      'question': 'Может ли пациент сидеть без поддержки?',
    },
  ];

  void calculateGMFCS() {
    int trueCount = answers.values.where((answer) => answer == true).length;

    int level;
    if (trueCount == 4) {
      level = 1;
    } else if (trueCount == 3) {
      level = 2;
    } else if (trueCount == 2) {
      level = 3;
    } else if (trueCount == 1) {
      level = 4;
    } else {
      level = 5;
    }

    setState(() {
      selectedLevel = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.thirdColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Изменение GMFCS',
          style: TextStyle(
            color: AppColors.thirdColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'TinosBold',
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ответьте на вопросы для переоценки функционального уровня',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: AppColors.text2Color,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                            padding: EdgeInsets.all(screenWidth * 0.05),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: AppColors.border3Color,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question['question'],
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.text2Color,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                Row(
                                  children: [
                                    Expanded(child: _buildCheckbox('Да', question['question'], true)),
                                    SizedBox(width: screenWidth * 0.05),
                                    Expanded(child: _buildCheckbox('Нет', question['question'], false)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (selectedLevel != null) ...[
                        SizedBox(height: screenHeight * 0.02),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.analytics, color: Colors.white, size: screenWidth * 0.1),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                'Ваш уровень GMFCS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                              Text(
                                'Уровень $selectedLevel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.08,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: screenHeight * 0.07,
                constraints: BoxConstraints(minHeight: 50, maxHeight: 70),
                decoration: BoxDecoration(
                  gradient: answers.length == questions.length
                      ? AppColors.primaryGradient
                      : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500]),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: answers.length == questions.length
                        ? () async {
                      if (selectedLevel == null) return;

                      try {
                        final success = await _dbService.setGMFCS(_localPatientId, selectedLevel!);
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Не удалось сохранить GMFCS')),
                          );
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('GMFCS уровень обновлён')),
                        );

                        Navigator.pop(context); // вернуться назад
                      } catch (e) {
                        print("Ошибка при сохранении GMFCS: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка сохранения GMFCS')),
                        );
                      }
                    }
                        : null,

                    child: Center(
                      child: Text(
                        'Изменить',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, String questionKey, bool value) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isSelected = answers[questionKey] == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          answers[questionKey] = value;
        });
        calculateGMFCS();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.03,
          horizontal: screenWidth * 0.04,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.text1Color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.text1Color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.05,
              height: screenWidth * 0.05,
              constraints: BoxConstraints(minWidth: 18, minHeight: 18, maxWidth: 24, maxHeight: 24),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.text1Color : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.text1Color : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: screenWidth * 0.035, color: Colors.white)
                  : null,
            ),
            SizedBox(width: screenWidth * 0.025),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.text1Color : AppColors.text2Color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
