import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neuro_control/presentation/pages/Diagnostics/lower_ortheses.dart';
import 'package:neuro_control/presentation/pages/Diagnostics/densitometr_page.dart';
import 'package:neuro_control/presentation/pages/Diagnostics/ortoped_page.dart';
import 'package:neuro_control/presentation/pages/Diagnostics/rentgen_page.dart';
import 'package:neuro_control/presentation/pages/Diagnostics/salivation_page.dart';
import 'package:neuro_control/presentation/pages/Diagnostics/upper_orthoses.dart';
import '../../assets/colors/app_colors.dart';
import '../../assets/data/texts/strings.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<MenuItemData> menuItems = [
    MenuItemData(
      title: 'Осмотр ортопеда',
      iconData: Icons.medical_services,
      color: const Color(0xFF66BB6A), // Более мягкий зеленый
      position: TilePosition.topLeft,
      builder: (context) => const OrtopedPage(patientId: '1', patientName: ''),
    ),
    MenuItemData(
      title: 'Рентгенография ТБС',
      iconData: Icons.camera_alt,
      color: const Color(0xFFFF974D), // Более мягкий оранжевый
      position: TilePosition.topRight,
      builder: (context) => const RentgenPage(patientId: "1", patientName: "test",),
    ),
    MenuItemData(
      title: 'Слюнотечение',
      iconData: Icons.water_drop,
      color: const Color(0xFF42A5F5), // Более мягкий голубой
      position: TilePosition.middleLeft,
      builder: (context) => const SalivationPage(),
    ),
    MenuItemData(
      title: 'Денситометрия',
      iconData: Icons.insights,
      color: const Color(0xFF26A66C), // Более мягкий бирюзовый
      position: TilePosition.middleRight,
      builder: (context) => const DensitometrPage(patientId: '1'),
    ),
    MenuItemData(
      title: 'Ортезы для верхних конечностей',
      iconData: Icons.back_hand,
      color: const Color(0xFFEC407A), // Более мягкий розовый
      position: TilePosition.bottomLeft,
      builder: (context) => const UpperOrthosesPage(),
    ),
    MenuItemData(
      title: 'Ортезы для нижних конечностей',
      iconData: Icons.accessibility_new,
      color: const Color(0xFFFFCA28), // Более мягкий желтый
      position: TilePosition.bottomRight,
      builder: (context) => const LowerOrthosesPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.primaryColor,
              iconTheme: const IconThemeData(color: AppColors.thirdColor),
              title: const Text(
                AppStrings.buttonStartTreeString,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'TinosBold',
                  color: AppColors.thirdColor,
                  fontSize: 21,
                ),
              ),
              pinned: true,
              expandedHeight: 140,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: const SafeArea(child: SizedBox.shrink()),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(20),
                child: Container(
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FE),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04, // 4% от ширины экрана
                vertical: 16,
              ),
              sliver: SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return DiagnosticsGrid(
                      menuItems: menuItems,
                      onTap: (item) => _navigateToPage(context, item),
                      animationController: _animationController,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, MenuItemData item) {
    if (!mounted) return;

    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        item.builder?.call(context) ?? PlaceholderPage(item: item),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubicEmphasized,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

enum TilePosition { topLeft, topRight, middleLeft, middleRight, bottomLeft, bottomRight }

class DiagnosticsGrid extends StatelessWidget {
  final List<MenuItemData> menuItems;
  final Function(MenuItemData) onTap;
  final AnimationController animationController;

  const DiagnosticsGrid({
    Key? key,
    required this.menuItems,
    required this.onTap,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = MediaQuery.of(context).size.height;

        // Адаптивные отступы и размеры
        final gap = screenWidth * 0.025; // 2.5% от ширины экрана
        final tileWidth = (screenWidth - gap) / 2;

        // Адаптивная высота плитки в зависимости от размера экрана
        double tileHeight;
        if (screenHeight > 800) {
          tileHeight = screenHeight * 0.18; // 18% от высоты экрана для больших экранов
        } else if (screenHeight > 600) {
          tileHeight = screenHeight * 0.16; // 16% для средних экранов
        } else {
          tileHeight = screenHeight * 0.14; // 14% для маленьких экранов
        }

        // Минимальная и максимальная высота
        tileHeight = tileHeight.clamp(120.0, 160.0);

        return Column(
          children: [
            // Первый ряд
            Row(
              children: [
                _buildTile(menuItems[0], tileWidth, tileHeight, 0),
                SizedBox(width: gap),
                _buildTile(menuItems[1], tileWidth, tileHeight, 1),
              ],
            ),
            SizedBox(height: gap),
            // Второй ряд
            Row(
              children: [
                _buildTile(menuItems[2], tileWidth, tileHeight, 2),
                SizedBox(width: gap),
                _buildTile(menuItems[3], tileWidth, tileHeight, 3),
              ],
            ),
            SizedBox(height: gap),
            // Третий ряд
            Row(
              children: [
                _buildTile(menuItems[4], tileWidth, tileHeight, 4),
                SizedBox(width: gap),
                _buildTile(menuItems[5], tileWidth, tileHeight, 5),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTile(MenuItemData item, double width, double height, int index) {
    return Expanded(
      child: DiagnosticTile(
        item: item,
        height: height,
        onTap: () => onTap(item),
        animationController: animationController,
        animationIndex: index,
      ),
    );
  }
}

class DiagnosticTile extends StatefulWidget {
  final MenuItemData item;
  final double height;
  final VoidCallback onTap;
  final AnimationController animationController;
  final int animationIndex;

  const DiagnosticTile({
    Key? key,
    required this.item,
    required this.height,
    required this.onTap,
    required this.animationController,
    required this.animationIndex,
  }) : super(key: key);

  @override
  State<DiagnosticTile> createState() => _DiagnosticTileState();
}

class _DiagnosticTileState extends State<DiagnosticTile> with TickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(
        widget.animationIndex * 0.1,
        (0.4 + widget.animationIndex * 0.1).clamp(0.0, 1.0),
        curve: Curves.easeOutExpo,
      ),
    ));

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(
        widget.animationIndex * 0.05,
        (0.3 + widget.animationIndex * 0.05).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    ));

    // Адаптивные размеры
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = (screenWidth * 0.065).clamp(24.0, 32.0); // Адаптивный размер иконки
    final fontSize = (screenWidth * 0.040).clamp(13.0, 16.0); // Адаптивный размер текста
    final containerSize = (screenWidth * 0.12).clamp(44.0, 52.0); // Адаптивный размер контейнера иконки

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: opacityAnimation,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: widget.height,
            transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
            decoration: BoxDecoration(
              color: widget.item.color,
              borderRadius: BorderRadius.circular(20), // Увеличенный радиус
              boxShadow: [
                BoxShadow(
                  color: widget.item.color.withOpacity(_isPressed ? 0.25 : 0.3), // Более мягкие тени
                  blurRadius: _isPressed ? 8 : 16,
                  offset: Offset(0, _isPressed ? 4 : 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.045), // Адаптивные отступы
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.item.color.withOpacity(0.95), // Более мягкий градиент
                    widget.item.color.withOpacity(0.75),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Иконка
                  Container(
                    width: containerSize,
                    height: containerSize,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25), // Более мягкий фон
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.item.iconData,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // Заголовок
                  Text(
                    widget.item.title,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'TinosBold',
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.02), // Адаптивный отступ
                  // Индикатор
                  Container(
                    width: screenWidth * 0.08, // Адаптивная ширина индикатора
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MenuItemData {
  final String title;
  final IconData iconData;
  final Color color;
  final TilePosition position;
  final Widget Function(BuildContext context)? builder;

  MenuItemData({
    required this.title,
    required this.iconData,
    required this.color,
    required this.position,
    this.builder,
  });
}

class PlaceholderPage extends StatelessWidget {
  final MenuItemData item;

  const PlaceholderPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: item.color,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'TinosBold',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.color,
                      ),
                      child: Icon(item.iconData, size: 36, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'TinosBold',
                        color: Color(0xFF1A202C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: item.color.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'В разработке',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: item.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Данный раздел находится в стадии разработки. Скоро здесь появится полная функциональность для работы с услугой "${item.title}".',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
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
}