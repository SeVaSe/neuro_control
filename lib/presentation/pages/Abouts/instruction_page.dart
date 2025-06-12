import 'package:flutter/material.dart';
import '../../../assets/data/texts/strings.dart';
import '../../screensTopic/topic_detail_instruction.dart';
import '../../../services/database_service.dart';
import '../../../database/entities/operation_manual.dart';
import '../../../assets/colors/app_colors.dart';

class OperationManualScreen extends StatefulWidget {
  const OperationManualScreen({Key? key}) : super(key: key);

  @override
  _OperationManualScreenState createState() => _OperationManualScreenState();
}

class _OperationManualScreenState extends State<OperationManualScreen> {
  final DatabaseService _databaseService = DatabaseService();

  List<OperationManual> allManuals = []; // Все инструкции по эксплуатации
  List<OperationManual> filteredManuals = []; // Отфильтрованные инструкции для поиска
  final TextEditingController searchController = TextEditingController();

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadManuals();
    searchController.addListener(_filterManuals);
  }

  /// Загрузка инструкций по эксплуатации из базы данных
  Future<void> _loadManuals() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final manuals = await _databaseService.getAllOperationManuals();

      setState(() {
        allManuals = manuals;
        filteredManuals = manuals;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Ошибка загрузки данных: $e';
        isLoading = false;
      });
      debugPrint('Ошибка загрузки инструкций: $e');
    }
  }

  /// Фильтрация инструкций по названию
  void _filterManuals() {
    final query = searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        filteredManuals = allManuals;
      } else {
        filteredManuals = allManuals
            .where((manual) =>
        manual.title.toLowerCase().contains(query) ||
            (manual.category?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  /// Обновление списка (pull-to-refresh)
  Future<void> _refreshManuals() async {
    await _loadManuals();
  }

  /// Переход к детальному просмотру инструкции
  void _navigateToDetail(OperationManual manual) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetailOperationScreen(
          title: manual.title,
          description: manual.description,
          category: manual.category,
          manualId: manual.id!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.thirdColor),
        title: const Text(
          'Инструкции по эксплуатации',
          style: TextStyle(
            fontFamily: 'TinosBold',
            fontWeight: FontWeight.bold,
            color: AppColors.thirdColor,
          ),
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Строка поиска
          Container(
            padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по названию или категории...',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isTablet ? 16 : 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.secondryColor,
                  size: isTablet ? 28 : 24,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[600],
                    size: isTablet ? 24 : 20,
                  ),
                  onPressed: () {
                    searchController.clear();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.secondryColor,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.secondryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.thirdColor,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 16 : 12,
                ),
              ),
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),

          // Основной контент
          Expanded(
            child: _buildMainContent(isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isTablet) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              'Загрузка инструкций...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isTablet ? 64 : 48,
              color: Colors.red[300],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            ElevatedButton.icon(
              onPressed: _loadManuals,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.thirdColor,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 14 : 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (filteredManuals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchController.text.isNotEmpty
                  ? Icons.search_off
                  : Icons.description_outlined,
              size: isTablet ? 64 : 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Text(
              searchController.text.isNotEmpty
                  ? 'Ничего не найдено'
                  : 'Инструкции отсутствуют',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (searchController.text.isNotEmpty) ...[
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                'Попробуйте изменить поисковый запрос',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshManuals,
      color: AppColors.primaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 12 : 8,
        ),
        itemCount: filteredManuals.length,
        itemBuilder: (context, index) {
          final manual = filteredManuals[index];
          return _buildManualCard(manual, isTablet);
        },
      ),
    );
  }

  Widget _buildManualCard(OperationManual manual, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToDetail(manual),
            child: Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Заголовок
                  Text(
                    manual.title,
                    style: TextStyle(
                      color: AppColors.thirdColor,
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Категория (если есть)
                  if (manual.category != null && manual.category!.isNotEmpty) ...[
                    SizedBox(height: isTablet ? 8 : 6),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 10,
                        vertical: isTablet ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.thirdColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        manual.category!,
                        style: TextStyle(
                          color: AppColors.thirdColor,
                          fontSize: isTablet ? 12 : 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  // Стрелка навигации
                  SizedBox(height: isTablet ? 12 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.thirdColor.withOpacity(0.7),
                        size: isTablet ? 18 : 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}