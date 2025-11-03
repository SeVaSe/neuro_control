import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UpperOrthosesPage extends StatefulWidget {
  const UpperOrthosesPage({Key? key}) : super(key: key);

  @override
  State<UpperOrthosesPage> createState() => _UpperOrthosesPageState();
}

class _UpperOrthosesPageState extends State<UpperOrthosesPage> {
  List<Orthosis> orthoses = [];
  bool isLoading = true;
  String searchQuery = '';
  String timeFilter = 'Все'; // Все, Дневной, Ночной, Дневной/Ночной
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadOrthoses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadOrthoses() async {
    try {
      setState(() {
        isLoading = true;
      });

      final String response = await rootBundle
          .loadString('lib/assets/data/json/upper_limb_orthoses.json');
      final data = json.decode(response);

      print('Загружены данные: $data'); // Для отладки

      if (data != null && data['orthoses'] != null) {
        setState(() {
          orthoses = (data['orthoses'] as List)
              .map((json) => Orthosis.fromJson(json))
              .toList();
          isLoading = false;
        });
        print('Количество загруженных ортезов: ${orthoses.length}'); // Для отладки
      } else {
        throw Exception('Неверная структура JSON файла');
      }
    } catch (e) {
      print('Ошибка загрузки данных: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Orthosis> get filteredOrthoses {
    List<Orthosis> filtered = orthoses;

    // Фильтр по времени использования
    if (timeFilter != 'Все') {
      filtered = filtered.where((orthosis) => orthosis.timeType == timeFilter).toList();
    }

    // Фильтр по поиску
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((orthosis) =>
      orthosis.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          orthosis.description.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 768;
    final crossAxisCount = isTablet ? 2 : 1;
    const primaryColor = Color(0xFFEC407A);
    const secondaryColor = Color(0xFFCA2D61);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ортезы для верхних конечностей',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar - всегда показываем
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Поиск ортезов...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFCA2D61)),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),

          // Time filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Тип использования:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Все', 'Дневной', 'Ночной', 'Дневной/Ночной'].map((filter) {
                        final isSelected = timeFilter == filter;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                timeFilter = filter;
                              });
                            },
                            selectedColor: primaryColor.withOpacity(0.12),
                            checkmarkColor: secondaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? secondaryColor : Colors.grey[600],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected ? secondaryColor : Colors.grey[300]!,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          // Results counter when searching or filter applied
          if (searchQuery.isNotEmpty || timeFilter != 'Все')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Найдено: ${filteredOrthoses.length} из ${orthoses.length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFCA2D61),
              ),
            )
                : orthoses.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Не удалось загрузить данные',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Проверьте файл upper_limb_orthoses.json',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : filteredOrthoses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ничего не найдено',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    searchQuery.isNotEmpty
                        ? 'По запросу "$searchQuery"'
                        : 'По выбранному фильтру',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: loadOrthoses,
              color: const Color(0xFFCA2D61),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isTablet ? 0.85 : 0.75,
                ),
                itemCount: filteredOrthoses.length,
                itemBuilder: (context, index) {
                  final orthosis = filteredOrthoses[index];
                  return OrthosisCard(
                    orthosis: orthosis,
                    onTap: () => _showOrthosisDetails(context, orthosis),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrthosisDetails(BuildContext context, Orthosis orthosis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrthosisDetailModal(orthosis: orthosis),
    );
  }
}

class OrthosisCard extends StatelessWidget {
  final Orthosis orthosis;
  final VoidCallback onTap;

  const OrthosisCard({
    Key? key,
    required this.orthosis,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDC4D82);
    const secondaryColor = Color(0xFFCA2D61);

    // badge color + icon depending on timeType
    Color badgeColor;
    IconData badgeIcon;
    switch (orthosis.timeType) {
      case 'Ночной':
        badgeColor = Colors.indigo.withOpacity(0.9);
        badgeIcon = Icons.nightlight_round;
        break;
      case 'Дневной/Ночной':
        badgeColor = Colors.teal.withOpacity(0.9);
        badgeIcon = Icons.brightness_4;
        break;
      default:
        badgeColor = Colors.orange.withOpacity(0.9);
        badgeIcon = Icons.wb_sunny;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    color: Colors.grey,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      orthosis.imagePath,
                      fit: BoxFit.contain, // Изменено с cover на contain
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.medical_services,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Time badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, size: 12, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          orthosis.timeType,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orthosis.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        orthosis.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCA2D61).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Color(0xFFCA2D61),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              orthosis.wearingMode,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFCA2D61),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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

class OrthosisDetailModal extends StatelessWidget {
  final Orthosis orthosis;

  const OrthosisDetailModal({Key? key, required this.orthosis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDC4D82);
    const secondaryColor = Color(0xFFCA2D61);

    Color badgeColor;
    IconData badgeIcon;
    switch (orthosis.timeType) {
      case 'Ночной':
        badgeColor = Colors.indigo.withOpacity(0.9);
        badgeIcon = Icons.nightlight_round;
        break;
      case 'Дневной/Ночной':
        badgeColor = Colors.teal.withOpacity(0.9);
        badgeIcon = Icons.brightness_4;
        break;
      default:
        badgeColor = Colors.orange.withOpacity(0.9);
        badgeIcon = Icons.wb_sunny;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Stack(
                        children: [
                          Container(
                            height: 300, // Увеличена высота
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey[100], // Добавлен фон
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                orthosis.imagePath,
                                fit: BoxFit.contain, // Изменено с cover на contain
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [primaryColor, secondaryColor],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.medical_services,
                                        size: 64,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(badgeIcon, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    orthosis.timeType,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      // Title
                      Text(
                        orthosis.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Функция',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFCA2D61),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              orthosis.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Wearing mode
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCA2D61).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFFCA2D61),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Режим ношения',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFCA2D61),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    orthosis.wearingMode,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
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

class Orthosis {
  final String imagePath;
  final String name;
  final String description;
  final String wearingMode;
  final String timeType; // новый параметр: 'Дневной', 'Ночной', 'Дневной/Ночной'

  Orthosis({
    required this.imagePath,
    required this.name,
    required this.description,
    required this.wearingMode,
    required this.timeType,
  });

  factory Orthosis.fromJson(Map<String, dynamic> json) {
    return Orthosis(
      imagePath: json['imagePath'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      wearingMode: json['wearingMode'] ?? '',
      timeType: json['timeType'] ?? 'Дневной',
    );
  }
}