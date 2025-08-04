import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import '../../assets/colors/app_colors.dart';
import '../../assets/data/texts/strings.dart';
import '../pages/Diagnostics/densitometr_page.dart';
import '../pages/Diagnostics/ortoped_page.dart';
import '../pages/Diagnostics/rentgen_page.dart';
import '../pages/Diagnostics/salivation_page.dart';

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
      duration: const Duration(milliseconds: 1400),
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
      title: 'Рентгенография',
      iconData: Icons.camera_alt_outlined,
      primaryColor: const Color(0xFFFF9A9E),
      secondaryColor: const Color(0xFFFECFEF),
      lightColor: const Color(0xFFFFF5F5),
      size: TileSize.medium,
      builder: (context) => const RentgenPage(orthopedicExaminationId: 1),
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
      size: TileSize.small,
      builder: (context) => const SalivationPage(),
    ),
    MenuItemData(
      title: 'Ортезы нижних конечностей',
      iconData: Icons.accessibility_new_outlined,
      primaryColor: const Color(0xFFFD79A8),
      secondaryColor: const Color(0xFFE84393),
      lightColor: const Color(0xFFFFF0F6),
      size: TileSize.small,
    ),
    MenuItemData(
      title: 'Ортезы верхних конечностей',
      iconData: Icons.back_hand_outlined,
      primaryColor: const Color(0xFFFDCB6E),
      secondaryColor: const Color(0xFFE17055),
      lightColor: const Color(0xFFFFFBF0),
      size: TileSize.large,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.primaryColor,
              iconTheme: const IconThemeData(
                color: AppColors.thirdColor,
              ),
              title: const Text(
                AppStrings.buttonStartTreeString,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'TinosBold',
                  color: AppColors.thirdColor,
                ),
              ),
              elevation: 0,
              pinned: true,
              expandedHeight: 130,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.primaryColor,
                  child: const SafeArea(
                    child: SizedBox.shrink(),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Container(
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBFBFD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
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

    if (item.builder != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => item.builder!(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaceholderPage(item: item)),
      );
    }
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
        return Column(
          children: _buildBrickRows(context, constraints.maxWidth),
        );
      },
    );
  }

  List<Widget> _buildBrickRows(BuildContext context, double screenWidth) {
    List<Widget> rows = [];
    int index = 0;

    while (index < menuItems.length) {
      List<Widget> rowChildren = [];
      double currentRowWidth = 0;

      while (index < menuItems.length && currentRowWidth < screenWidth) {
        final item = menuItems[index];
        final tileWidth = _getTileWidth(item.size, screenWidth);

        if (currentRowWidth + tileWidth <= screenWidth || rowChildren.isEmpty) {
          rowChildren.add(
            Expanded(
              flex: _getTileFlex(item.size),
              child: MenuTile(
                item: item,
                onTap: () => onTap(item),
                animationController: animationController,
                animationIndex: index,
              ),
            ),
          );
          currentRowWidth += tileWidth;
          index++;
        } else {
          break;
        }
      }

      if (rowChildren.isNotEmpty) {
        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rowChildren,
            ),
          ),
        );
      }
    }

    return rows;
  }

  double _getTileWidth(TileSize size, double screenWidth) {
    switch (size) {
      case TileSize.small:
        return screenWidth * 0.33;
      case TileSize.medium:
        return screenWidth * 0.5;
      case TileSize.large:
        return screenWidth;
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
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Start floating animation with delay
    Future.delayed(Duration(milliseconds: widget.animationIndex * 200), () {
      if (mounted) {
        _floatingController.repeat(reverse: true);
      }
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
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(
        widget.animationIndex * 0.1,
        (0.5 + widget.animationIndex * 0.1).clamp(0.0, 1.0),
        curve: Curves.elasticOut,
      ),
    ));

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(
        widget.animationIndex * 0.05,
        (0.4 + widget.animationIndex * 0.05).clamp(0.0, 1.0),
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
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: _getTileHeight(widget.item.size),
                transform: Matrix4.identity()
                  ..scale(_isPressed ? 0.95 : 1.0)
                  ..translate(0.0, _isPressed ? 4.0 : (_floatingAnimation.value * 3 - 1.5)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.item.lightColor,
                      Colors.white,
                      widget.item.lightColor.withOpacity(0.3),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  border: Border.all(
                    color: widget.item.primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.item.primaryColor.withOpacity(_isPressed ? 0.1 : 0.15),
                      blurRadius: _isPressed ? 8 : 20,
                      offset: Offset(0, _isPressed ? 2 : 10),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 1,
                      offset: const Offset(0, -1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Subtle pattern overlay
                    Positioned.fill(
                      child: CustomPaint(
                        painter: MinimalPatternPainter(
                          color: widget.item.primaryColor.withOpacity(0.03),
                          animation: _floatingAnimation,
                        ),
                      ),
                    ),
                    // Gradient accent
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.item.primaryColor,
                              widget.item.secondaryColor,
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
                          // Icon with elegant background
                          Container(
                            width: _getIconSize(widget.item.size),
                            height: _getIconSize(widget.item.size),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.item.primaryColor.withOpacity(0.1),
                                  widget.item.secondaryColor.withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(
                                color: widget.item.primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              widget.item.iconData,
                              size: _getIconSize(widget.item.size) * 0.5,
                              color: widget.item.primaryColor,
                            ),
                          ),
                          const Spacer(),
                          // Title with modern typography
                          Text(
                            widget.item.title,
                            style: TextStyle(
                              fontSize: _getTitleSize(widget.item.size),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'TinosBold',
                              color: const Color(0xFF2D3748),
                              height: 1.1,
                              letterSpacing: -0.3,
                            ),
                            maxLines: widget.item.size == TileSize.small ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: _getPadding(widget.item.size) * 0.3),
                          // Minimal progress dots
                          Row(
                            children: List.generate(3, (index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                width: index == 0 ? _getAccentLineWidth(widget.item.size) : 6,
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      widget.item.primaryColor.withOpacity(index == 0 ? 0.8 : 0.3),
                                      widget.item.secondaryColor.withOpacity(index == 0 ? 0.6 : 0.2),
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
        return 150;
      case TileSize.medium:
        return 170;
      case TileSize.large:
        return 190;
    }
  }

  double _getPadding(TileSize size) {
    switch (size) {
      case TileSize.small:
        return 24;
      case TileSize.medium:
        return 28;
      case TileSize.large:
        return 32;
    }
  }

  double _getIconSize(TileSize size) {
    switch (size) {
      case TileSize.small:
        return 44;
      case TileSize.medium:
        return 52;
      case TileSize.large:
        return 60;
    }
  }

  double _getTitleSize(TileSize size) {
    switch (size) {
      case TileSize.small:
        return 15;
      case TileSize.medium:
        return 17;
      case TileSize.large:
        return 20;
    }
  }

  double _getAccentLineWidth(TileSize size) {
    switch (size) {
      case TileSize.small:
        return 32;
      case TileSize.medium:
        return 40;
      case TileSize.large:
        return 48;
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

    // Subtle floating circles
    for (int i = 0; i < 3; i++) {
      final radius = (2 + i * 1.5) + (animValue * 0.5);
      final x = size.width * (0.7 + i * 0.1);
      final y = size.height * (0.2 + i * 0.15) + (animValue * 2);

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
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: item.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'TinosBold',
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, item.lightColor],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: item.primaryColor.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [item.primaryColor, item.secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(item.iconData, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'TinosBold',
                        color: Color(0xFF2D3748),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: item.primaryColor.withOpacity(0.1), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            item.primaryColor.withOpacity(0.1),
                            item.secondaryColor.withOpacity(0.05)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'В разработке',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: item.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Данный раздел находится в стадии разработки. Скоро здесь появится полная функциональность для работы с услугой "${item.title}".',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
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