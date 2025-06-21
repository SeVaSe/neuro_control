import 'package:flutter/material.dart';
import '../../assets/data/texts/strings.dart';
import '../screensTopic/topic_detail_manual.dart';
import '../../services/database_service.dart';
import '../../database/entities/reference_guide.dart';
import '../../assets/colors/app_colors.dart';
import 'package:flutter/services.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({Key? key}) : super(key: key);

  @override
  _ManualScreenState createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  List<ReferenceGuide> allGuides = [];
  List<ReferenceGuide> filteredGuides = [];
  final TextEditingController searchController = TextEditingController();

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGuides();
    searchController.addListener(_filterGuides);
  }

  Future<void> _loadGuides() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final guides = await _databaseService.getAllReferenceGuides();

      setState(() {
        allGuides = guides;
        filteredGuides = guides;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Ошибка загрузки данных: $e';
        isLoading = false;
      });
    }
  }

  void _filterGuides() {
    final query = searchController.text.toLowerCase().trim();

    setState(() {
      filteredGuides = query.isEmpty
          ? allGuides
          : allGuides.where((guide) =>
      guide.title.toLowerCase().contains(query) ||
          (guide.category?.toLowerCase().contains(query) ?? false)).toList();
    });
  }

  Future<void> _refreshGuides() async {
    await _loadGuides();
  }

  void _navigateToDetail(ReferenceGuide guide) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetailScreen(
          title: guide.title,
          content: guide.content,
          category: guide.category,
          guideId: guide.id!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: AppColors.primaryColor,
              iconTheme: const IconThemeData(color: AppColors.thirdColor),
              title: const Text(
                AppStrings.buttonStartManualString,
                style: TextStyle(
                  fontFamily: 'TinosBold',
                  fontWeight: FontWeight.bold,
                  color: AppColors.thirdColor,
                ),
              ),
              elevation: 0,
              pinned: true,
              floating: false,
              snap: false,
              expandedHeight: 130,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(color: AppColors.primaryColor),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),

                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
            SliverToBoxAdapter(
              child: Padding(
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
            ),
          ];
        },
        body: _buildMainContent(isTablet),
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
              'Загрузка справочника...',
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
              onPressed: _loadGuides,
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

    if (filteredGuides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchController.text.isNotEmpty
                  ? Icons.search_off
                  : Icons.library_books_outlined,
              size: isTablet ? 64 : 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Text(
              searchController.text.isNotEmpty
                  ? 'Ничего не найдено'
                  : 'Справочник пуст',
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
      onRefresh: _refreshGuides,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 12 : 8,
        ),
        itemCount: filteredGuides.length,
        itemBuilder: (context, index) {
          final guide = filteredGuides[index];
          return _buildGuideCard(guide, isTablet);
        },
      ),
    );
  }

  Widget _buildGuideCard(ReferenceGuide guide, bool isTablet) {
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
            onTap: () => _navigateToDetail(guide),
            child: Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Заголовок
                  Text(
                    guide.title,
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
                  if (guide.category != null && guide.category!.isNotEmpty) ...[
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
                        guide.category!,
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
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }
}