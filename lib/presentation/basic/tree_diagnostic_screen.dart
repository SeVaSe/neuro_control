import 'package:flutter/material.dart';
import 'dart:math' as math;

class TreeDiagnosticScreen extends StatefulWidget {
  const TreeDiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<TreeDiagnosticScreen> createState() => _TreeDiagnosticScreenState();
}

class _TreeDiagnosticScreenState extends State<TreeDiagnosticScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  TransformationController _transformController = TransformationController();

  List<NodeData> nodes = [];
  List<ConnectionData> connections = [];
  bool _showHelp = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _generateNodes();
    _startAnimation();
  }

  void _generateNodes() {
    nodes = [
      NodeData(
        id: 'root',
        title: 'Главный узел',
        position: const Offset(400, 300),
        color: Colors.blue,
        size: 20,
        level: 0,
      ),
      NodeData(
        id: 'analysis',
        title: 'Анализ данных',
        position: const Offset(200, 150),
        color: Colors.blue,
        size: 16,
        level: 1,
      ),
      NodeData(
        id: 'reports',
        title: 'Отчеты',
        position: const Offset(600, 150),
        color: Colors.blue,
        size: 16,
        level: 1,
      ),
      NodeData(
        id: 'settings',
        title: 'Настройки',
        position: const Offset(300, 450),
        color: Colors.blue,
        size: 16,
        level: 1,
      ),
      NodeData(
        id: 'database',
        title: 'База данных',
        position: const Offset(500, 450),
        color: Colors.blue,
        size: 16,
        level: 1,
      ),
      NodeData(
        id: 'charts',
        title: 'Графики',
        position: const Offset(100, 80),
        color: Colors.blue,
        size: 14,
        level: 2,
      ),
      NodeData(
        id: 'statistics',
        title: 'Статистика',
        position: const Offset(300, 80),
        color: Colors.blue,
        size: 14,
        level: 2,
      ),
      NodeData(
        id: 'export',
        title: 'Экспорт',
        position: const Offset(650, 80),
        color: Colors.blue,
        size: 14,
        level: 2,
      ),
      NodeData(
        id: 'sharing',
        title: 'Sharing',
        position: const Offset(750, 200),
        color: Colors.blue,
        size: 14,
        level: 2,
      ),
    ];

    connections = [
      ConnectionData('root', 'analysis'),
      ConnectionData('root', 'reports'),
      ConnectionData('root', 'settings'),
      ConnectionData('root', 'database'),
      ConnectionData('analysis', 'charts'),
      ConnectionData('analysis', 'statistics'),
      ConnectionData('reports', 'export'),
      ConnectionData('reports', 'sharing'),
    ];
  }

  void _startAnimation() {
    _fadeController.forward();

    // Запускаем анимацию узлов с задержкой
    for (int i = 0; i < nodes.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          setState(() {
            nodes[i].isVisible = true;
          });
        }
      });
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _onNodeTap(NodeData node) {
    // Анимация нажатия
    setState(() {
      node.isPressed = true;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        node.isPressed = false;
      });
    });

    // Показываем сообщение о разработке
    _showDevelopmentMessage(node.title);
  }

  void _showDevelopmentMessage(String nodeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.construction,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'В разработке',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Раздел "$nodeName" находится в разработке.\nСкоро здесь появится новый функционал!',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Понятно',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    setState(() {
      _showHelp = true;
    });
  }

  void _hideHelpDialog() {
    setState(() {
      _showHelp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Фоновая сетка
          CustomPaint(
            painter: GridPainter(),
            size: Size.infinite,
          ),

          // Основное полотно с графом
          InteractiveViewer(
            transformationController: _transformController,
            minScale: 0.3,
            maxScale: 3.0,
            constrained: false,
            child: SizedBox(
              width: 1000,
              height: 800,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: CustomPaint(
                      painter: TreePainter(
                        nodes: nodes,
                        connections: connections,
                        animation: _scaleAnimation,
                        onNodeTap: _onNodeTap,
                      ),
                      size: const Size(1000, 800),
                    ),
                  );
                },
              ),
            ),
          ),

          // Верхняя панель управления
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Кнопка назад
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black87,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Назад',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Заголовок
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Диагностическое дерево',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Кнопка справки
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: _showHelpDialog,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.help_outline,
                              color: Colors.black87,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Справка',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Панель справки
          if (_showHelp)
            GestureDetector(
              onTap: _hideHelpDialog,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(40),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a1a1a),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.purple,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Справка по использованию',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildHelpItem(
                          Icons.touch_app,
                          'Навигация',
                          'Используйте жесты для перемещения и масштабирования полотна',
                        ),
                        _buildHelpItem(
                          Icons.radio_button_checked,
                          'Узлы',
                          'Нажимайте на цветные узлы для перехода в соответствующие разделы',
                        ),
                        _buildHelpItem(
                          Icons.timeline,
                          'Связи',
                          'Линии показывают связи между различными компонентами системы',
                        ),
                        _buildHelpItem(
                          Icons.animation,
                          'Анимации',
                          'Узлы появляются с красивыми анимационными эффектами',
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: _hideHelpDialog,
                            child: Text(
                              'Закрыть',
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Индикатор масштаба
          Positioned(
            bottom: 30,
            right: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.zoom_in,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Используйте жесты для навигации',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.purple,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NodeData {
  final String id;
  final String title;
  final Offset position;
  final Color color;
  final double size;
  final int level;
  bool isVisible;
  bool isPressed;

  NodeData({
    required this.id,
    required this.title,
    required this.position,
    required this.color,
    required this.size,
    required this.level,
    this.isVisible = false,
    this.isPressed = false,
  });
}

class ConnectionData {
  final String fromId;
  final String toId;

  ConnectionData(this.fromId, this.toId);
}

class TreePainter extends CustomPainter {
  final List<NodeData> nodes;
  final List<ConnectionData> connections;
  final Animation<double> animation;
  final Function(NodeData) onNodeTap;

  TreePainter({
    required this.nodes,
    required this.connections,
    required this.animation,
    required this.onNodeTap,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    _drawConnections(canvas);
    _drawNodes(canvas);
  }

  void _drawConnections(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final connection in connections) {
      final fromNode = nodes.firstWhere((n) => n.id == connection.fromId);
      final toNode = nodes.firstWhere((n) => n.id == connection.toId);

      if (fromNode.isVisible && toNode.isVisible) {
        // Простая прямая линия
        canvas.drawLine(
          fromNode.position,
          toNode.position,
          paint,
        );
      }
    }
  }

  void _drawParticles(Canvas canvas, Path path) {
    final particlePaint = Paint()
      ..color = Colors.purple.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      for (double distance = 0; distance < metric.length; distance += 50) {
        final pos = metric.getTangentForOffset(distance);
        if (pos != null) {
          final animatedRadius = 2 * animation.value;
          canvas.drawCircle(pos.position, animatedRadius, particlePaint);
        }
      }
    }
  }

  void _drawNodes(Canvas canvas) {
    for (final node in nodes) {
      if (node.isVisible) {
        _drawNode(canvas, node);
      }
    }
  }

  void _drawNode(Canvas canvas, NodeData node) {
    final animatedScale = animation.value;
    final pressedScale = node.isPressed ? 0.9 : 1.0;
    final finalScale = animatedScale * pressedScale;

    if (finalScale <= 0) return;

    // Основной узел - простой синий кружок
    final nodePaint = Paint()
      ..color = node.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      node.position,
      node.size * finalScale,
      nodePaint,
    );

    // Белая обводка
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      node.position,
      node.size * finalScale,
      borderPaint,
    );
  }

  void _drawNodeText(Canvas canvas, NodeData node, double scale) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.title,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 10 * scale,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final textPosition = Offset(
      node.position.dx - textPainter.width / 2,
      node.position.dy + node.size * scale + 8,
    );

    textPainter.paint(canvas, textPosition);
  }

  void _drawPulseEffect(Canvas canvas, NodeData node, double scale) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final pulseScale = 1.0 + math.sin(time * 2) * 0.1;

    final pulsePaint = Paint()
      ..color = node.color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      node.position,
      node.size * scale * pulseScale,
      pulsePaint,
    );
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.nodes != nodes ||
        oldDelegate.connections != connections;
  }

  @override
  bool hitTest(Offset position) {
    for (final node in nodes) {
      if (node.isVisible) {
        final distance = (position - node.position).distance;
        if (distance <= node.size) {
          onNodeTap(node);
          return true;
        }
      }
    }
    return false;
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    const gridSize = 50.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}