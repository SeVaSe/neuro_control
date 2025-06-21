import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      duration: const Duration(milliseconds: 1000),
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
      description: 'Подзаголовок осмотр ортопеда...',
      iconData: Icons.medical_services_outlined,
      color: const Color(0xFF6C63FF),
      lightColor: const Color(0xFFE8E6FF),
    ),
    MenuItemData(
      title: 'Рентгенография',
      description: 'Подзаголовок рентографии...',
      iconData: Icons.medical_information_outlined,
      color: const Color(0xFFFF6B6B),
      lightColor: const Color(0xFFFFE8E8),
    ),
    MenuItemData(
      title: 'Денситометрия',
      description: 'Подзаголовок денситометрии...',
      iconData: Icons.analytics_outlined,
      color: const Color(0xFF4ECDC4),
      lightColor: const Color(0xFFE8FFFD),
    ),
    MenuItemData(
      title: 'Слюнотечение',
      description: 'Подзаголовок слюнотечение...',
      iconData: Icons.water_drop_outlined,
      color: const Color(0xFF45B7D1),
      lightColor: const Color(0xFFE8F7FF),
    ),
    MenuItemData(
      title: 'Ортезы нижних конечностей',
      description: 'Подзаголовок ортезы...',
      iconData: Icons.build_outlined,
      color: const Color(0xFFFF8A65),
      lightColor: const Color(0xFFFFF2E8),
    ),
    MenuItemData(
      title: 'Ортезы верхних конечностей',
      description: 'Подзаголовок ортезы...',
      iconData: Icons.build_outlined,
      color: const Color(0xFFFFC965),
      lightColor: const Color(0xFFFFF3E1),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // AppBar с заголовком и описанием как единое целое
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
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                  ),
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

            // Menu items
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final slideAnimation = Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            index * 0.1,
                            (0.7 + index * 0.1).clamp(0.0, 1.0),
                            curve: Curves.easeOutCubic,
                          ),
                        ));

                        final opacityAnimation = Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            index * 0.1,
                            (0.7 + index * 0.1).clamp(0.0, 1.0),
                            curve: Curves.easeOut,
                          ),
                        ));

                        return SlideTransition(
                          position: slideAnimation,
                          child: FadeTransition(
                            opacity: opacityAnimation,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: MenuCard(
                                item: menuItems[index],
                                onTap: () => _navigateToPage(context, menuItems[index]),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: menuItems.length,
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

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PlaceholderPage(item: item),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class MenuCard extends StatefulWidget {
  final MenuItemData item;
  final VoidCallback onTap;

  const MenuCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (mounted) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (mounted) {
          setState(() => _isPressed = false);
          widget.onTap();
        }
      },
      onTapCancel: () {
        if (mounted) {
          setState(() => _isPressed = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.98 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.item.color.withOpacity(0.15),
                blurRadius: _isPressed ? 8 : 12,
                offset: Offset(0, _isPressed ? 2 : 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: widget.item.lightColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.item.iconData,
                    size: 28,
                    color: widget.item.color,
                  ),
                ),
                const SizedBox(width: 20),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          fontFamily: 'TinosBold',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.item.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: widget.item.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MenuItemData {
  final String title;
  final String description;
  final IconData iconData;
  final Color color;
  final Color lightColor;

  MenuItemData({
    required this.title,
    required this.description,
    required this.iconData,
    required this.color,
    required this.lightColor,
  });
}

// Заглушка для страниц
class PlaceholderPage extends StatelessWidget {
  final MenuItemData item;

  const PlaceholderPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: item.color,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
            // Hero section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.15),
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
                        color: item.lightColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        item.iconData,
                        size: 48,
                        color: item.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'TinosBold',
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.description,
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

            const SizedBox(height: 32),

            // Status card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: item.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: item.lightColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'В разработке',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: item.color,
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