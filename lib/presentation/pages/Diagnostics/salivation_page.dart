import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

import '../../../services/database_service.dart';
import '../../../services/reminder_scheduler.dart';

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
  List<dynamic> _allSalivationRecords = [];
  DateTime? _nextTestDate;

  // Хранение ответов на вопросы (0-10 баллов)
  List<int> _answers = List.filled(10, -1); // -1 означает не выбрано

  // Цвета
  final Color _blueColor = const Color(0xFF74B9FF);
  final Color _darkBlueColor = const Color(0xFF0984E3);
  final Color _yellowColor = const Color(0xFFFFC107);

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
      final allRecords = await _databaseService.getSalivations(patientId);

      setState(() {
        _allSalivationRecords = allRecords;
        if (latestSalivation != null) {
          _testCompleted = true;
          _totalScore = latestSalivation.complicationScore;
          _recommendation = _totalScore >= 10
              ? "Рекомендуется направление на ботулинотерапию"
              : "Слюнотечение в пределах нормы, дополнительного лечения не требуется";
          _nextTestDate = latestSalivation.createdAt.add(const Duration(days: 90));
        }
      });
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

      // Устанавливаем дату следующего теста (через 3 месяца)
      final now = DateTime.now();
      _nextTestDate = DateTime(now.year, now.month + 3, now.day);


      // Добавляем напоминание в календарь
      await _addCalendarReminder();

      final scheduler = ReminderScheduler(_databaseService);
      await scheduler.scheduleReminder(
        patientId: patientId,
        appointmentDateTime: _nextTestDate!,
        title: 'Пройти Анкету по слюнотечению',
        description: 'У вас скоро запланировано прохождение Акеты по слюнотечению. Не забудьте провести данное обследование в приложении NeuroOrto.control!',
      );

      // Обновляем список записей
      final updatedRecords = await _databaseService.getSalivations(patientId);

      setState(() {
        _testCompleted = true;
        _showQuestionnaire = false;
        _allSalivationRecords = updatedRecords;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Результаты сохранены! Напоминание добавлено в календарь через 3 месяца.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCalendarReminder() async {
    try {
      if (_nextTestDate != null) {
        final Event event = Event(
          title: 'Тест на слюнотечение',
          description: 'Время пройти повторный тест на слюнотечение',
          location: 'Дом',
          startDate: _nextTestDate!,
          endDate: _nextTestDate!.add(const Duration(hours: 1)),
          iosParams: const IOSParams(
            reminder: Duration(hours: 1),
          ),
          androidParams: const AndroidParams(
            emailInvites: [],
          ),
        );

        await Add2Calendar.addEvent2Cal(event);
        print('Напоминание добавлено в календарь на дату: $_nextTestDate');
      }
    } catch (e) {
      print('Ошибка добавления в календарь: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось добавить напоминание в календарь'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _startNewTest() {
    setState(() {
      _answers = List.filled(10, -1);
      _showQuestionnaire = true;
      _testCompleted = false;
      _totalScore = 0;
      _recommendation = "";
    });
  }

  void _navigateToFolder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalivationFolderPage(records: _allSalivationRecords),
      ),
    );
  }

  bool get _allQuestionsAnswered {
    return _answers.every((answer) => answer >= 0);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showQuestionnaire) {
          setState(() {
            _showQuestionnaire = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Слюнотечение',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: _blueColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_showQuestionnaire) {
                setState(() {
                  _showQuestionnaire = false;
                });
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _showQuestionnaire
            ? _buildQuestionnaire()
            : _buildMainScreen(),
      ),
    );
  }

  Widget _buildMainScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildActionCards(),
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
                _blueColor.withOpacity(0.1),
                _darkBlueColor.withOpacity(0.05),
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
                      color: _blueColor,
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
                      'Слюнотечение – это',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0984E3),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: _blueColor,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Слюнотечение или сиалорея, также известная как гиперсаливация или птиализм, это состояние, характеризующееся избыточным слюноотделением...',
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
                  color: _blueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _blueColor.withOpacity(0.3),
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
                      color: _blueColor,
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

  Widget _buildActionCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 16) / 2;
        final cardHeight = cardWidth * 1.1;

        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: cardHeight,
                child: GestureDetector(
                  onTap: _startNewTest,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _blueColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _blueColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.assignment,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Анкета',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _testCompleted ? 'Пройдено' : 'Пройти тест',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        if (_nextTestDate != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Следующий:',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                  ),
                                ),
                                Text(
                                  '${_getDaysUntilNextTest()} дн.',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: cardHeight,
                child: GestureDetector(
                  onTap: _navigateToFolder,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _yellowColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _yellowColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.folder,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Папка\nслюнотечения',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_allSalivationRecords.length} записей',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int _getDaysUntilNextTest() {
    if (_nextTestDate == null) return 0;
    final now = DateTime.now();
    final difference = _nextTestDate!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  void _showInfoDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
                  colors: [_blueColor, _darkBlueColor],
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
                      'Слюнотечение или сиалорея, также известная как гиперсаливация или птиализм, это состояние, характеризующееся избыточным слюноотделением, когда количество слюны, выделяемой слюнными железами, превышает норму. Это состояние может быть вызвано различными факторами, включая заболевания нервной системы, слюнных желез, а также другие медицинские состояния.',
                      Icons.help_outline,
                    ),
                    _buildInfoSection(
                      'Симптомы сиалореи',
                      'Основной симптом сиалореи - избыточное слюноотделение, которое может проявляться как постоянное подтекание слюны изо рта, так и ощущением избыточной слюны во рту. Это может приводить к следующим проблемам:\n\n• Неприятный запах изо рта (галитоз)\n• Затруднения при приеме пищи и глотании\n• Нарушения речи\n• Раздражение и мацерация кожи вокруг рта\n• Увеличение риска инфекций ротовой полости и кожи\n• Социальная изоляция и снижение самооценки',
                      Icons.medical_services_outlined,
                    ),
                    _buildInfoSection(
                      'Типы сиалореи',
                      'Передняя сиалорея характеризуется вытеканием слюны изо рта, часто называемым слюнотечением.\n\nЗадняя сиалорея, напротив, означает стекание слюны по задней стенке глотки, что может приводить к поперхиванию и аспирации (попаданию слюны в дыхательные пути).',
                      Icons.category_outlined,
                    ),
                    _buildInfoSection(
                      'Основные риски',
                      'Основные риски включают:\n\n• Обезвоживание и нарушение электролитного баланса из-за потери жидкости\n• Развитие кожных проблем, таких как периоральный дерматит\n• Наиболее опасным осложнением является аспирационная пневмония, возникающая из-за попадания слюны в дыхательные пути, особенно у людей с нарушениями глотания\n• Сиалорея может негативно влиять на социальную адаптацию и качество жизни',
                      Icons.warning_outlined,
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
                  color: _blueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: _blueColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _darkBlueColor,
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

  Widget _buildQuestionnaire() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _blueColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Text(
                  'Пройдите анкету',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _answers.where((a) => a >= 0).length / _questions.length,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_answers.where((a) => a >= 0).length} из ${_questions.length} вопросов',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
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
                      ? _blueColor
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
                color: _blueColor,
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
                activeTrackColor: _blueColor,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: _darkBlueColor,
                overlayColor: _blueColor.withOpacity(0.2),
                valueIndicatorColor: _darkBlueColor,
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
                        ? _darkBlueColor
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
                  color: _blueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Выбрано: ${_answers[index]} баллов',
                  style: TextStyle(
                    fontSize: 12,
                    color: _darkBlueColor,
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

class SalivationFolderPage extends StatelessWidget {
  final List<dynamic> records;

  const SalivationFolderPage({Key? key, required this.records}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Папка слюнотечения',
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
      body: records.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Нет сохраненных записей',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF74B9FF),
                child: Text(
                  '${record.complicationScore}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                'Балл: ${record.complicationScore}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0984E3)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.notes ?? 'Без примечаний'),
                  const SizedBox(height: 4),
                  Text(
                    'Дата: ${_formatDate(record.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: record.complicationScore >= 10
                  ? const Icon(Icons.warning, color: Colors.orange)
                  : const Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}