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
      iconData: Icons.medical_services_outlined,
      primaryColor: const Color(0xFF667EEA),
      secondaryColor: const Color(0xFF764BA2),
      lightColor: const Color(0xFFF0F2FF),
      size: TileSize.large,
      builder: (context) => const OrtopedPage(patientId: '1', patientName: ''),
    ),
    MenuItemData(
      title: 'Денситометрия',
      iconData: Icons.insights_outlined,
      primaryColor: const Color(0xFF96E6A1),
      secondaryColor: const Color(0xFFD4FC79),
      lightColor: const Color(0xFFF0FFF4),
      size: TileSize.medium,
      builder: (context) => const DensitometrPage(patientId: '1'),
    ),
    MenuItemData(
      title: 'Слюнотечение',
      iconData: Icons.water_drop_outlined,
      primaryColor: const Color(0xFF74B9FF),
      secondaryColor: const Color(0xFF0984E3),
      lightColor: const Color(0xFFEBF8FF),
      size: TileSize.medium,
      builder: (context) => const SalivationPage(),
    ),
    MenuItemData(
      title: 'Ортезы нижних конечностей',
      iconData: Icons.accessibility_new_outlined,
      primaryColor: const Color(0xFFFD79A8),
      secondaryColor: const Color(0xFFE84393),
      lightColor: const Color(0xFFFFF0F6),
      size: TileSize.small,
      builder: (context) => const LowerOrthosesPage(),
    ),
    MenuItemData(
      title: 'Ортезы верхних конечностей',
      iconData: Icons.back_hand_outlined,
      primaryColor: const Color(0xFFFDCB6E),
      secondaryColor: const Color(0xFFE17055),
      lightColor: const Color(0xFFFFFBF0),
      size: TileSize.small,
      builder: (context) => const UpperOrthosesPage(),
    ),
    MenuItemData(
      title: 'Рентгенография',
      iconData: Icons.camera_alt_outlined,
      primaryColor: const Color(0xFFFF6B6B),
      secondaryColor: const Color(0xFFFECFEF),
      lightColor: const Color(0xFFFFF5F5),
      size: TileSize.large,
      builder: (context) => const RentgenPage(orthopedicExaminationId: 1, patientId: "1"),
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
                  fontWeight: FontWeight.w700,
                  fontFamily: 'TinosBold',
                  color: AppColors.thirdColor,
                  fontSize: 20,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return BrickLayout(
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

enum TileSize { small, medium, large }

class BrickLayout extends StatelessWidget {
  final List<MenuItemData> menuItems;
  final Function(MenuItemData) onTap;
  final AnimationController animationController;

  const BrickLayout({
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
        final gap = 12.0;
        return Column(
          children: _buildBrickRows(context, screenWidth, gap),
        );
      },
    );
  }

  List<Widget> _buildBrickRows(BuildContext context, double screenWidth, double gap) {
    List<Widget> rows = [];
    int index = 0;

    while (index < menuItems.length) {
      List<Widget> rowChildren = [];
      double currentRowWidth = 0;

      while (index < menuItems.length && currentRowWidth < screenWidth) {
        final item = menuItems[index];
        final tileWidth = _getTileWidth(item.size, screenWidth, gap);

        if (currentRowWidth + tileWidth <= screenWidth || rowChildren.isEmpty) {
          rowChildren.add(
            Expanded(
              flex: _getTileFlex(item.size),
              child: Padding(
                padding: EdgeInsets.only(right: rowChildren.isNotEmpty ? gap : 0),
                child: MenuTile(
                  item: item,
                  onTap: () => onTap(item),
                  animationController: animationController,
                  animationIndex: index,
                ),
              ),
            ),
          );
          currentRowWidth += tileWidth + (rowChildren.length > 1 ? gap : 0);
          index++;
        } else {
          break;
        }
      }

      if (rowChildren.isNotEmpty) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(bottom: gap),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rowChildren,
              ),
            ),
          ),
        );
      }
    }

    return rows;
  }

  double _getTileWidth(TileSize size, double screenWidth, double gap) {
    final availableWidth = screenWidth - gap * 2;
    switch (size) {
      case TileSize.small:
        return availableWidth * 0.33;
      case TileSize.medium:
        return availableWidth * 0.5;
      case TileSize.large:
        return availableWidth;
    }
  }

  int _getTileFlex(TileSize size) {
    switch (size) {
      case TileSize.small:
        return 1;
      case TileSize.medium:
        return 2;
      case TileSize.large:
        return 3;
    }
  }
}

class MenuTile extends StatefulWidget {
  final MenuItemData item;
  final VoidCallback onTap;
  final AnimationController animationController;
  final int animationIndex;

  const MenuTile({
    Key? key,
    required this.item,
    required this.onTap,
    required this.animationController,
    required this.animationIndex,
  }) : super(key: key);

  @override
  State<MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<MenuTile> with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOutSine),
    );
    Future.delayed(Duration(milliseconds: widget.animationIndex * 150), () {
      if (mounted) _floatingController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(
        widget.animationIndex * 0.08,
        (0.4 + widget.animationIndex * 0.08).clamp(0.0, 1.0),
        curve: Curves.easeOutExpo,
      ),
    ));

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(
        widget.animationIndex * 0.04,
        (0.3 + widget.animationIndex * 0.04).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: opacityAnimation,
        child: AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: _getTileHeight(widget.item.size),
                transform: Matrix4.identity()
                  ..scale(_isPressed ? 0.97 : 1.0)
                  ..translate(0.0, _isPressed ? 3.0 : (_floatingAnimation.value * 2 - 1)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.item.lightColor,
                      Colors.white.withOpacity(0.9),
                      widget.item.lightColor.withOpacity(0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.item.primaryColor.withOpacity(_isPressed ? 0.08 : 0.12),
                      blurRadius: _isPressed ? 6 : 12,
                      offset: Offset(0, _isPressed ? 2 : 6),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      blurRadius: 2,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Subtle pattern overlay
                    Positioned.fill(
                      child: CustomPaint(
                        painter: MinimalPatternPainter(
                          color: widget.item.primaryColor.withOpacity(0.04),
                          animation: _floatingAnimation,
                        ),
                      ),
                    ),
                    // Gradient accent
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.item.primaryColor.withOpacity(0.9),
                              widget.item.secondaryColor.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.all(_getPadding(widget.item.size)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            width: _getIconSize(widget.item.size),
                            height: _getIconSize(widget.item.size),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.item.primaryColor.withOpacity(0.15),
                                  widget.item.secondaryColor.withOpacity(0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.item.primaryColor.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.item.iconData,
                              size: _getIconSize(widget.item.size) * 0.55,
                              color: widget.item.primaryColor,
                            ),
                          ),
                          const Spacer(),
                          // Title
                          Text(
                            widget.item.title,
                            style: TextStyle(
                              fontSize: _getTitleSize(widget.item.size),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'TinosBold',
                              color: const Color(0xFF1A202C),
                              height: 1.2,
                              letterSpacing: -0.2,
                            ),
                            maxLines: widget.item.size == TileSize.small ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: _getPadding(widget.item.size) * 0.4),
                          // Progress dots
                          Row(
                            children: List.generate(3, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 5),
                                width: index == 0 ? _getAccentLineWidth(widget.item.size) : 5,
                                height: 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    colors: [
                                      widget.item.primaryColor.withOpacity(index == 0 ? 0.9 : 0.4),
                                      widget.item.secondaryColor.withOpacity(index == 0 ? 0.7 : 0.3),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _getTileHeight(TileSize size) {
    switch (size) {
      case TileSize.small:
        return 140;
      case TileSize.medium:
        return 160;
      case TileSize.large:
        return 180;
    }
  }

  double _getPadding(TileSize size) {
    switch (size) {
      case TileSize.small:
        return 16;
      case TileSize.medium:
        return 20;
      case TileSize.large:
        return 24;
    }
  }

  double _getIconSize(TileSize size) {
    switch (size) {
      case TileSize.small:
        return 40;
      case TileSize.medium:
        return 48;
      case TileSize.large:
        return 56;
    }
  }

  double _getTitleSize(TileSize size) {
    switch (size) {
      case TileSize.small:
        return 14;
      case TileSize.medium:
        return 16;
      case TileSize.large:
        return 18;
    }
  }

  double _getAccentLineWidth(TileSize size) {
    switch (size) {
      case TileSize.small:
        return 28;
      case TileSize.medium:
        return 36;
      case TileSize.large:
        return 44;
    }
  }
}

class MinimalPatternPainter extends CustomPainter {
  final Color color;
  final Animation<double> animation;

  MinimalPatternPainter({required this.color, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final animValue = animation.value;

    // Subtle geometric pattern
    for (int i = 0; i < 4; i++) {
      final radius = (2 + i * 1) + (animValue * 0.3);
      final x = size.width * (0.6 + i * 0.15);
      final y = size.height * (0.15 + i * 0.1) + (animValue * 1.5);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MenuItemData {
  final String title;
  final IconData iconData;
  final Color primaryColor;
  final Color secondaryColor;
  final Color lightColor;
  final TileSize size;
  final Widget Function(BuildContext context)? builder;

  MenuItemData({
    required this.title,
    required this.iconData,
    required this.primaryColor,
    required this.secondaryColor,
    required this.lightColor,
    required this.size,
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
        backgroundColor: item.primaryColor,
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
                gradient: LinearGradient(
                  colors: [Colors.white, item.lightColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: item.primaryColor.withOpacity(0.08),
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
                        gradient: LinearGradient(
                          colors: [item.primaryColor, item.secondaryColor],
                        ),
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
                border: Border.all(color: item.primaryColor.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            item.primaryColor.withOpacity(0.15),
                            item.secondaryColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'В разработке',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: item.primaryColor,
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