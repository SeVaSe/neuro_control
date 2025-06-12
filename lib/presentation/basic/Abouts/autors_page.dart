import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../assets/colors/app_colors.dart';

class AuthorsScreen extends StatelessWidget {
  const AuthorsScreen({Key? key}) : super(key: key);

  final List<Author> authors = const [
    Author(
      fullName: "Табе Евгения",
      photoUrl: "lib/assets/imgs/imgAutorDoctor.png",
      title: "Руководитель",
      bio: "Врач травматолог-ортопед, Кандидат медицинских наук",
      projectRole: "Создатель идеи проекта, эксперт. Разработала концепцию, участвовала в проектировании, консультировала по медицинским вопросам, формулировала медицинские термины, давала рекомендации по улучшению функционала и определяла направление развития приложения. Руководила этапами разработки",
      position: "Руководитель проекта",
      interests: "ДЦП, Орфанная патология, Состояния после инсультов",
      socialLinks: {
        'website': "https://drtabe.ukit.me",
        'telegram': "https://t.me/doctor_tabe",
        'email': "dr.tabe@mail.ru",
        'vk': "https://vk.com/e.tabe",
      },
    ),
    Author(
      fullName: "Севастьянов Константин",
      photoUrl: "lib/assets/imgs/imgAutorProgrammer.png",
      title: "Разработчик",
      bio: "Инженер-программист",
      projectRole: "Разработчик приложения, технический архитектор. Полностью реализовал техническую часть проекта, включая разработку структуры приложения, написание кода и оптимизацию работы. Участвовал в проектировании, предлагал и внедрял новые идеи, обеспечивал стабильность и безопасность системы",
      position: "Разработчик",
      interests: "Системное программирование, Computer vision, Мобильная разработка",
      socialLinks: {
        'website': "https://sevase.github.io/sevasek/",
        'telegram': "https://t.me/sevasek",
        'email': "sevasek.inter@gmail.com"
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.thirdColor,
      appBar: AppBar(
        title: const Text(
          "Наши авторы",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'TinosBold',
            color: AppColors.thirdColor,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.thirdColor),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        itemCount: authors.length,
        itemBuilder: (context, index) {
          final author = authors[index];
          return AuthorCard(author: author);
        },
      ),
    );
  }
}

class Author {
  final String fullName;
  final String photoUrl;
  final String title;
  final String bio;
  final String projectRole;
  final String position;
  final String interests;
  final Map<String, String> socialLinks;

  const Author({
    required this.fullName,
    required this.photoUrl,
    required this.title,
    required this.bio,
    required this.projectRole,
    required this.position,
    required this.interests,
    required this.socialLinks,
  });
}

class AuthorCard extends StatefulWidget {
  final Author author;

  const AuthorCard({Key? key, required this.author}) : super(key: key);

  @override
  _AuthorCardState createState() => _AuthorCardState();
}

class _AuthorCardState extends State<AuthorCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Основная информация автора
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              children: [
                // Фото автора
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: (screenWidth * 0.1).clamp(30.0, 50.0),
                    backgroundImage: AssetImage(widget.author.photoUrl),
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),

                // Информация об авторе
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.author.fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: (screenWidth * 0.045).clamp(16.0, 22.0),
                          color: AppColors.secondryColor,
                          fontFamily: 'TinosBold',
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        widget.author.title,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        widget.author.bio,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: (screenWidth * 0.032).clamp(11.0, 14.0),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Кнопка раскрытия
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: AppColors.primaryColor,
                        size: (screenWidth * 0.06).clamp(20.0, 28.0),
                      ),
                    ),
                    onPressed: _toggleExpanded,
                  ),
                ),
              ],
            ),
          ),

          // Разделитель
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            height: 1,
            color: Colors.grey.withOpacity(0.2),
          ),

          // Развернутая информация
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    "Роль в проекте",
                    widget.author.projectRole,
                    screenWidth,
                    Icons.work_outline,
                  ),
                  _buildSection(
                    "Сфера интересов",
                    widget.author.interests,
                    screenWidth,
                    Icons.star_outline,
                  ),
                  _buildSocialLinks(widget.author.socialLinks, screenWidth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, double screenWidth, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryColor,
                size: (screenWidth * 0.045).clamp(16.0, 20.0),
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                title,
                style: TextStyle(
                  fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            content,
            style: TextStyle(
              fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
              color: AppColors.text2Color,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(Map<String, String> socialLinks, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_mail,
                color: AppColors.primaryColor,
                size: (screenWidth * 0.045).clamp(16.0, 20.0),
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                "Контакты:",
                style: TextStyle(
                  fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          Wrap(
            spacing: screenWidth * 0.03,
            runSpacing: screenWidth * 0.02,
            children: socialLinks.entries.map((entry) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () => _launchURL(entry.value),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenWidth * 0.02,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSocialIcon(entry.key),
                          color: AppColors.primaryColor,
                          size: (screenWidth * 0.04).clamp(16.0, 20.0),
                        ),
                        SizedBox(width: screenWidth * 0.015),
                        Text(
                          _getSocialLabel(entry.key),
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: (screenWidth * 0.032).clamp(11.0, 14.0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getSocialIcon(String type) {
    switch (type) {
      case 'website':
        return Icons.language;
      case 'telegram':
        return Icons.telegram;
      case 'email':
        return Icons.email;
      case 'vk':
        return Icons.group;
      default:
        return Icons.link;
    }
  }

  String _getSocialLabel(String type) {
    switch (type) {
      case 'website':
        return 'Сайт';
      case 'telegram':
        return 'Telegram';
      case 'email':
        return 'Почта';
      case 'vk':
        return 'ВКонтакте';
      default:
        return 'Ссылка';
    }
  }

  void _launchURL(String url) async {
    String finalUrl = url;

    // Добавляем 'mailto:', если это email-адрес
    if (!url.startsWith('mailto:') &&
        !url.startsWith('http') &&
        !url.startsWith('https') &&
        url.contains('@')) {
      finalUrl = 'mailto:$url';
    }

    final Uri uri = Uri.parse(finalUrl);

    try {
      final success = await launchUrl(uri);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Не удалось открыть ссылку',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ошибка при открытии ссылки: $e',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}