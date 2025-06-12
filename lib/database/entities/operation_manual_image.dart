class OperationManualImage {
  final int? id;
  final int operationManualId;
  final String imagePath;
  final String? description;
  final int orderIndex;
  final DateTime createdAt;

  OperationManualImage({
    this.id,
    required this.operationManualId,
    required this.imagePath,
    this.description,
    this.orderIndex = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation_manual_id': operationManualId,
      'image_path': imagePath,
      'description': description,
      'order_index': orderIndex,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory OperationManualImage.fromMap(Map<String, dynamic> map) {
    return OperationManualImage(
      id: map['id'],
      operationManualId: map['operation_manual_id'],
      imagePath: map['image_path'],
      description: map['description'],
      orderIndex: map['order_index'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}
