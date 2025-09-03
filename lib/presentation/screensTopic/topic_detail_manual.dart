import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../database/entities/reference_guide.dart';
import '../../assets/colors/app_colors.dart';

class TopicDetailScreen extends StatefulWidget {
  final String title;
  final String content;
  final String? category;
  final int guideId;
  final ReferenceType referenceType;
  final String? pdfPath;

  const TopicDetailScreen({
    Key? key,
    required this.title,
    required this.content,
    this.category,
    required this.guideId,
    this.referenceType = ReferenceType.database,
    this.pdfPath,
  }) : super(key: key);

  @override
  _TopicDetailScreenState createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.thirdColor),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'TinosBold',
            fontWeight: FontWeight.bold,
            color: AppColors.thirdColor,
          ),
        ),
        elevation: 0,
      ),
      body: widget.referenceType == ReferenceType.pdf
          ? _buildPdfContent()
          : _buildDatabaseContent(isTablet),
    );
  }

  // ---------------------------
  // Контент для PDF файлов
  // ---------------------------
  Widget _buildPdfContent() {
    final path = widget.pdfPath;

    if (path == null || path.isEmpty) {
      return const _CenteredInfo(
        icon: Icons.picture_as_pdf_outlined,
        title: 'PDF не найден',
        subtitle: 'Путь к файлу не задан',
      );
    }

    // Явно ожидаем путь от корня lib:
    // lib/assets/data/pdf/your_file.pdf
    if (!path.startsWith('lib/assets/data/pdf/')) {
      return _ErrorPanel(
        message:
        'Ожидается путь вида:\nlib/assets/data/pdf/<имя_файла>.pdf\nПолучено:\n$path',
      );
    }

    return SfPdfViewer.asset(
      path, // без каких-либо преобразований
      enableDoubleTapZooming: true,
      enableTextSelection: true,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      canShowPaginationDialog: true,
      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки PDF: ${details.error}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text('PDF загружен. Страниц: ${details.document.pages.count}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  // ---------------------------
  // Контент для записей БД
  // ---------------------------
  Widget _buildDatabaseContent(bool isTablet) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Заголовок с информацией
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.primaryColor,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.category != null &&
                          widget.category!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16 : 12,
                            vertical: isTablet ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.thirdColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.category!,
                            style: TextStyle(
                              color: AppColors.thirdColor,
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Закругленный переход
                Container(
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Контент
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 8 : 4,
            ),
            child: _buildContent(isTablet),
          ),
        ),
      ],
    );
  }

  // Построение контента для БД записей
  Widget _buildContent(bool isTablet) {
    if (widget.content.isEmpty) {
      return const _CenteredInfo(
        icon: Icons.description_outlined,
        title: 'Контент недоступен',
        subtitle: 'Содержимое отсутствует',
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      margin: EdgeInsets.only(bottom: isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок "Содержание"
          Row(
            children: [
              Icon(
                Icons.article_outlined,
                color: AppColors.primaryColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                'Содержание',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Основной текст
          Text(
            widget.content,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: isTablet ? 16 : 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// ---------------------------
// Вспомогательные виджеты
// ---------------------------

class _CenteredInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _CenteredInfo({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: isTablet ? 40 : 32),
          Icon(
            icon,
            size: isTablet ? 64 : 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: isTablet ? 14 : 12,
              ),
            ),
          ],
          SizedBox(height: isTablet ? 40 : 32),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  const _ErrorPanel({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.06),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.red.shade800,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
