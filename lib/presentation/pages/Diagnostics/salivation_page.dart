import 'package:flutter/material.dart';

import '../../../services/database_service.dart';

class SalivationPage extends StatefulWidget {
  const SalivationPage({Key? key}) : super(key: key);

  @override
  State<SalivationPage> createState() => _SalivationPageState();
}

class _SalivationPageState extends State<SalivationPage> {
  final DatabaseService _databaseService = DatabaseService();
  final String patientId = "1"; // Локальный пациент с ID 1

  bool _showQuestionnaire = false;
  bool _isLoading = false;
  bool _testCompleted = false;
  int _totalScore = 0;
  String _recommendation = "";

  // Хранение ответов на вопросы (0-10 баллов)
  List<int> _answers = List.filled(10, -1); // -1 означает не выбрано

  // Вопросы теста
  final List<Map<String, String>> _questions = [
    {
      'question': 'Как часто у Вашего ребенка подтекает слюна?',
      'leftLabel': 'Никогда',
      'rightLabel': 'Постоянно'
    },
    {
      'question': 'Насколько выражено слюнотечение?',
      'leftLabel': 'Ребенок сухой',
      'rightLabel': 'Профузное слюнотечение'
    },
    {
      'question': 'Сколько раз в день Вам приходится менять ребенку слюнявчики или другую одежду из-за слюнотечения?',
      'leftLabel': 'Однократно',
      'rightLabel': '10 раз'
    },
    {
      'question': 'Как часто от Вашего ребенка пахнет слюной?',
      'leftLabel': 'Не часто',
      'rightLabel': 'Очень часто'
    },
    {
      'question': 'Какие повреждения кожи возникают у Вашего ребенка из-за слюнотечения?',
      'leftLabel': 'Никаких',
      'rightLabel': 'Выраженная сыпь'
    },
    {
      'question': 'Как часто Вам приходится вытирать ребенку рот из-за слюнотечения?',
      'leftLabel': 'Никогда',
      'rightLabel': 'Постоянно'
    },
    {
      'question': 'Насколько Вашего ребенка смущает избыточное слюнотечение?',
      'leftLabel': 'Не смущает',
      'rightLabel': 'Очень смущает'
    },
    {
      'question': 'Как часто Вам приходится стирать слюну ребенка с игрушек, предметов мебели?',
      'leftLabel': 'Никогда',
      'rightLabel': 'Постоянно'
    },
    {
      'question': 'Насколько избыточное слюнотечение мешает повседневной активности ребенка?',
      'leftLabel': 'Нисколько',
      'rightLabel': 'Очень мешает'
    },
    {
      'question': 'Насколько избыточное слюнотечение у ребенка нарушает Вашу повседневную жизнь и жизнь других членов семьи?',
      'leftLabel': 'Нисколько',
      'rightLabel': 'Очень мешает'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    setState(() => _isLoading = true);
    try {
      final latestSalivation = await _databaseService.getLatestSalivation(patientId);
      if (latestSalivation != null) {
        setState(() {
          _testCompleted = true;
          _totalScore = latestSalivation.complicationScore;
          _recommendation = _totalScore >= 10
              ? "Рекомендуется направление на ботулинотерапию"
              : "Слюнотечение в пределах нормы, дополнительного лечения не требуется";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveResults() async {
    setState(() => _isLoading = true);
    try {
      _totalScore = _answers.reduce((a, b) => a + b);
      _recommendation = _totalScore >= 10
          ? "Рекомендуется направление на ботулинотерапию"
          : "Слюнотечение в пределах нормы, дополнительного лечения не требуется";

      await _databaseService.addSalivation(
        patientId,
        _totalScore,
        notes: _recommendation,
      );

      setState(() {
        _testCompleted = true;
        _showQuestionnaire = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Результаты сохранены!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startNewTest() {
    setState(() {
      _answers = List.filled(10, -1); // -1 означает не выбрано
      _showQuestionnaire = true;
      _testCompleted = false;
      _totalScore = 0;
      _recommendation = "";
    });
  }

  bool get _allQuestionsAnswered {
    return _answers.every((answer) => answer >= 0); // теперь 0 - валидный ответ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Оценка слюнотечения',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF74B9FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showQuestionnaire
          ? _buildQuestionnaire()
          : _buildMainScreen(),
    );
  }

  Widget _buildMainScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Карточка справки
          _buildInfoCard(),
          const SizedBox(height: 16),
          // Карточка анкеты/результатов
          _buildQuestionnaireCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showInfoDetails(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF74B9FF).withOpacity(0.1),
                const Color(0xFF0984E3).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF74B9FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Справка о слюнотечении',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0984E3),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: const Color(0xFF74B9FF),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Слюнотечение (сиалорея) — избыточное выделение слюны, которое может значительно влиять на качество жизни ребенка и семьи.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF74B9FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF74B9FF).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Нажмите для подробной информации',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF0984E3),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.touch_app,
                      color: const Color(0xFF74B9FF),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionnaireCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _testCompleted
                        ? Colors.green
                        : const Color(0xFF0984E3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _testCompleted ? Icons.assignment_turned_in : Icons.assignment,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _testCompleted ? 'Результаты теста' : 'Тест на слюнотечение',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0984E3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_testCompleted) ...[
              _buildResults(),
            ] else ...[
              const Text(
                'Пройдите тест из 10 вопросов для оценки степени слюнотечения у вашего ребенка.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startNewTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF74B9FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Начать тест',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showInfoDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF74B9FF),
                    const Color(0xFF0984E3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Подробно о слюнотечении',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(
                      'Что такое слюнотечение?',
                      'Слюнотечение (сиалорея) — это состояние, при котором происходит избыточное выделение слюны или нарушение её проглатывания. Это может быть как нормальным явлением в определённом возрасте, так и признаком различных неврологических или анатомических нарушений.',
                      Icons.help_outline,
                    ),
                    _buildInfoSection(
                      'Причины слюнотечения',
                      '• Неврологические нарушения (ДЦП, аутизм)\n• Анатомические особенности\n• Прорезывание зубов\n• Побочные эффекты лекарств\n• Инфекции полости рта\n• Гастроэзофагеальный рефлюкс',
                      Icons.medical_services_outlined,
                    ),
                    _buildInfoSection(
                      'Влияние на качество жизни',
                      'Избыточное слюнотечение может существенно влиять на:\n• Социальную активность ребёнка\n• Речевое развитие\n• Состояние кожи вокруг рта\n• Повседневную жизнь семьи\n• Самооценку ребёнка',
                      Icons.sentiment_dissatisfied_outlined,
                    ),
                    _buildInfoSection(
                      'Методы лечения',
                      '• Логопедические упражнения\n• Медикаментозная терапия\n• Ботулинотерапия (инъекции ботокса)\n• Хирургические методы\n• Физиотерапия\n• Поведенческая терапия',
                      Icons.healing_outlined,
                    ),
                    _buildInfoSection(
                      'О шкале оценки',
                      'Данная шкала позволяет объективно оценить степень выраженности слюнотечения и его влияние на повседневную жизнь. Результат в 10 и более баллов указывает на необходимость специализированного лечения, включая возможность ботулинотерапии.',
                      Icons.assessment_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF74B9FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF74B9FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0984E3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final bool needsTreatment = _totalScore >= 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: needsTreatment
                ? Colors.orange.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: needsTreatment
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.green.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Text(
                'Общий балл: $_totalScore',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: needsTreatment ? Colors.orange[700] : Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _recommendation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: needsTreatment ? Colors.orange[800] : Colors.green[800],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startNewTest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0984E3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Пройти тест заново',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionnaire() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return _buildQuestionCard(index);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _allQuestionsAnswered ? _saveResults : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _allQuestionsAnswered
                      ? const Color(0xFF74B9FF)
                      : Colors.grey[300],
                  foregroundColor: _allQuestionsAnswered
                      ? Colors.white
                      : Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _allQuestionsAnswered ? 2 : 0,
                ),
                child: Text(
                  _allQuestionsAnswered
                      ? 'Сохранить результаты'
                      : 'Ответьте на все вопросы',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Вопрос ${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF74B9FF),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _questions[index]['question']!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _questions[index]['leftLabel']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _questions[index]['rightLabel']!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF74B9FF),
                inactiveTrackColor: Colors.grey[300],
                thumbColor: const Color(0xFF0984E3),
                overlayColor: const Color(0xFF74B9FF).withOpacity(0.2),
                valueIndicatorColor: const Color(0xFF0984E3),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              ),
              child: Slider(
                value: _answers[index] == -1 ? 0 : _answers[index].toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                label: _answers[index] == -1 ? '' : _answers[index].toString(),
                onChanged: (value) {
                  setState(() {
                    _answers[index] = value.toInt();
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(11, (i) {
                return Text(
                  i.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: _answers[index] == i
                        ? const Color(0xFF0984E3)
                        : Colors.grey[400],
                    fontWeight: _answers[index] == i
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              }),
            ),
            if (_answers[index] >= 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF74B9FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Выбрано: ${_answers[index]} баллов',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0984E3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}