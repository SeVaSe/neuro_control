class PhotoRecord {
  final int? id;
  final int orthopedicExaminationId;
  final String imagePath;
  final String? description;
  final DateTime createdAt;

  PhotoRecord({
    this.id,
    required this.orthopedicExaminationId,
    required this.imagePath,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orthopedic_examination_id': orthopedicExaminationId,
      'image_path': imagePath,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PhotoRecord.fromMap(Map<String, dynamic> map) {
    return PhotoRecord(
      id: map['id'],
      orthopedicExaminationId: map['orthopedic_examination_id'],
      imagePath: map['image_path'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}
