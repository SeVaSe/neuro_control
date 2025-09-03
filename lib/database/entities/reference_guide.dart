// reference_guide.dart
class ReferenceGuide {
  final int? id;
  final String title;
  final String content;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Новые поля для поддержки PDF
  final ReferenceType type; // БД или PDF
  final String? pdfPath; // Путь к PDF файлу
  final bool isPdfLoaded; // Загружен ли PDF контент

  ReferenceGuide({
    this.id,
    required this.title,
    required this.content,
    this.category,
    required this.createdAt,
    required this.updatedAt,
    this.type = ReferenceType.database,
    this.pdfPath,
    this.isPdfLoaded = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'type': type.name,
      'pdf_path': pdfPath,
      'is_pdf_loaded': isPdfLoaded ? 1 : 0,
    };
  }

  factory ReferenceGuide.fromMap(Map<String, dynamic> map) {
    return ReferenceGuide(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      type: ReferenceType.values.firstWhere(
            (e) => e.name == (map['type'] ?? 'database'),
        orElse: () => ReferenceType.database,
      ),
      pdfPath: map['pdf_path'],
      isPdfLoaded: (map['is_pdf_loaded'] ?? 0) == 1,
    );
  }

  // Конструктор для создания PDF записи
  factory ReferenceGuide.fromPdf({
    int? id,
    required String title,
    required String pdfPath,
    String? category,
    String content = '',
  }) {
    final now = DateTime.now();
    return ReferenceGuide(
      id: id,
      title: title,
      content: content,
      category: category,
      createdAt: now,
      updatedAt: now,
      type: ReferenceType.pdf,
      pdfPath: pdfPath,
      isPdfLoaded: content.isNotEmpty,
    );
  }

  ReferenceGuide copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    ReferenceType? type,
    String? pdfPath,
    bool? isPdfLoaded,
  }) {
    return ReferenceGuide(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      pdfPath: pdfPath ?? this.pdfPath,
      isPdfLoaded: isPdfLoaded ?? this.isPdfLoaded,
    );
  }

  // Проверяет, нужно ли загрузить контент
  bool get needsContentLoading => type == ReferenceType.pdf && !isPdfLoaded;

  // Проверяет, готов ли для отображения
  bool get isReadyForDisplay => type == ReferenceType.database || isPdfLoaded;
}

enum ReferenceType {
  database, // Данные из БД
  pdf,      // PDF файл
}