import 'package:flutter/material.dart';
import '../../models/operation_manual_model.dart';
import '../../assets/colors/app_colors.dart';

class TopicDetailOperationScreen extends StatefulWidget {
  final OperationManualModel manual;

  const TopicDetailOperationScreen({
    Key? key,
    required this.manual,
  }) : super(key: key);

  @override
  _TopicDetailOperationScreenState createState() =>
      _TopicDetailOperationScreenState();
}

class _TopicDetailOperationScreenState
    extends State<TopicDetailOperationScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.thirdColor),
        title: Text(
          widget.manual.title,
          style: const TextStyle(
            fontFamily: 'TinosBold',
            fontWeight: FontWeight.bold,
            color: AppColors.thirdColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Категория
            if (widget.manual.category.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.manual.category,
                  style: TextStyle(
                    color: AppColors.thirdColor,
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),
            ],

            // Заголовок
            Text(
              widget.manual.title,
              style: TextStyle(
                fontSize: isTablet ? 26 : 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
                height: 1.3,
              ),
            ),

            SizedBox(height: isTablet ? 24 : 20),

            // Рендеринг контента
            ...widget.manual.content
                .map((block) => _buildContentBlock(block, isTablet))
                .toList(),

            // Дополнительное пространство внизу
            SizedBox(height: isTablet ? 32 : 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBlock(ContentBlock block, bool isTablet) {
    if (block is TextBlock) {
      return _buildTextBlock(block, isTablet);
    } else if (block is HeadingBlock) {
      return _buildHeadingBlock(block, isTablet);
    } else if (block is ImageBlock) {
      return _buildImageBlock(block, isTablet);
    } else if (block is ListBlock) {
      return _buildListBlock(block, isTablet);
    } else if (block is NumberedListBlock) {
      return _buildNumberedListBlock(block, isTablet);
    } else if (block is WarningBlock) {
      return _buildWarningBlock(block, isTablet);
    } else if (block is InfoBlock) {
      return _buildInfoBlock(block, isTablet);
    } else if (block is GalleryBlock) {
      return _buildGalleryBlock(block, isTablet);
    } else if (block is TableBlock) {
      return _buildTableBlock(block, isTablet);
    } else if (block is QuoteBlock) {
      return _buildQuoteBlock(block, isTablet);
    } else if (block is DividerBlock) {
      return _buildDividerBlock(isTablet);
    } else if (block is VideoBlock) {
      return _buildVideoBlock(block, isTablet);
    }

    return const SizedBox.shrink();
  }

  // Text Block
  Widget _buildTextBlock(TextBlock block, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: SelectableText(
        block.text,
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Heading Block
  Widget _buildHeadingBlock(HeadingBlock block, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(
        top: isTablet ? 24 : 20,
        bottom: isTablet ? 12 : 10,
      ),
      child: Text(
        block.text,
        style: TextStyle(
          fontSize: isTablet ? 22 : 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
          height: 1.3,
        ),
      ),
    );
  }

  // Image Block
  Widget _buildImageBlock(ImageBlock block, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showImageDialog(block.path, block.description),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                block.path,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                            size: isTablet ? 64 : 48,
                          ),
                          SizedBox(height: isTablet ? 12 : 8),
                          Text(
                            'Изображение не найдено',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (block.caption != null && block.caption!.isNotEmpty) ...[
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              block.caption!,
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // List Block
  Widget _buildListBlock(ListBlock block, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.title != null && block.title!.isNotEmpty) ...[
            Text(
              block.title!,
              style: TextStyle(
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isTablet ? 8 : 6),
          ],
          ...block.items.map((item) => Padding(
            padding: EdgeInsets.only(
              bottom: isTablet ? 6 : 4,
              left: isTablet ? 16 : 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // Numbered List Block
  Widget _buildNumberedListBlock(NumberedListBlock block, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.title != null && block.title!.isNotEmpty) ...[
            Text(
              block.title!,
              style: TextStyle(
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isTablet ? 8 : 6),
          ],
          ...block.items.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: isTablet ? 6 : 4,
                left: isTablet ? 16 : 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$index. ',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Warning Block
  Widget _buildWarningBlock(WarningBlock block, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[300]!, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red[700],
              size: isTablet ? 28 : 24,
            ),
            SizedBox(width: isTablet ? 12 : 10),
            Expanded(
              child: Text(
                block.text,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[900],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Info Block
  Widget _buildInfoBlock(InfoBlock block, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[300]!, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue[700],
              size: isTablet ? 28 : 24,
            ),
            SizedBox(width: isTablet ? 12 : 10),
            Expanded(
              child: Text(
                block.text,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  color: Colors.blue[900],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Gallery Block
  Widget _buildGalleryBlock(GalleryBlock block, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.title != null && block.title!.isNotEmpty) ...[
            Text(
              block.title!,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 10),
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              crossAxisSpacing: isTablet ? 12 : 8,
              mainAxisSpacing: isTablet ? 12 : 8,
              childAspectRatio: 1.2,
            ),
            itemCount: block.images.length,
            itemBuilder: (context, index) {
              final image = block.images[index];
              return GestureDetector(
                onTap: () => _showImageDialog(image.path, image.description),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Image.asset(
                          image.path,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[400],
                                size: isTablet ? 32 : 24,
                              ),
                            );
                          },
                        ),
                        if (image.description != null &&
                            image.description!.isNotEmpty)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(isTablet ? 6 : 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: Text(
                                image.description!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 11 : 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Table Block
  Widget _buildTableBlock(TableBlock block, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Headers
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: block.headers
                    .map((header) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    child: Text(
                      header,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.thirdColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
            // Rows
            ...block.rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              return Container(
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.grey[50] : Colors.white,
                ),
                child: Row(
                  children: row
                      .map((cell) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 12 : 10),
                      child: Text(
                        cell,
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 12,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ))
                      .toList(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Quote Block
  Widget _buildQuoteBlock(QuoteBlock block, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.primaryColor,
              width: 4,
            ),
          ),
          color: Colors.grey[100],
        ),
        child: Row(
          children: [
            Icon(
              Icons.format_quote,
              color: AppColors.primaryColor.withOpacity(0.3),
              size: isTablet ? 32 : 28,
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: Text(
                block.text,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Divider Block
  Widget _buildDividerBlock(bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
      child: Divider(
        thickness: 2,
        color: Colors.grey[300],
      ),
    );
  }

  // Video Block
  Widget _buildVideoBlock(VideoBlock block, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.asset(
                block.thumbnail,
                width: double.infinity,
                height: isTablet ? 250 : 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: isTablet ? 250 : 200,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.videocam_off,
                      color: Colors.grey[400],
                      size: isTablet ? 64 : 48,
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: isTablet ? 80 : 64,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          block.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 15 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (block.duration != null &&
                          block.duration!.isNotEmpty) ...[
                        SizedBox(width: isTablet ? 12 : 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 8 : 6,
                            vertical: isTablet ? 4 : 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            block.duration!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 12 : 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Image Dialog
  void _showImageDialog(String imagePath, String? description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 64,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Не удалось загрузить изображение',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              if (description != null && description.isNotEmpty)
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}