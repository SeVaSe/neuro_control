class ReferenceGuideImage {
  final int? id;
  final int referenceGuideId;
  final String imagePath;
  final String? description;
  final int orderIndex; // Порядок отображения изображений
  final DateTime createdAt;

  ReferenceGuideImage({
    this.id,
    required this.referenceGuideId,
    required this.imagePath,
    this.description,
    this.orderIndex = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference_guide_id': referenceGuideId,
      'image_path': imagePath,
      'description': description,
      'order_index': orderIndex,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ReferenceGuideImage.fromMap(Map<String, dynamic> map) {
    return ReferenceGuideImage(
      id: map['id'],
      referenceGuideId: map['reference_guide_id'],
      imagePath: map['image_path'],
      description: map['description'],
      orderIndex: map['order_index'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}
