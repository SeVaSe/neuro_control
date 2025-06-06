class Densitometry {
  final int? id;
  final String patientId;
  final String imagePath;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Densitometry({
    this.id,
    required this.patientId,
    required this.imagePath,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'image_path': imagePath,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Densitometry.fromMap(Map<String, dynamic> map) {
    return Densitometry(
      id: map['id'],
      patientId: map['patient_id'],
      imagePath: map['image_path'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  Densitometry copyWith({
    int? id,
    String? patientId,
    String? imagePath,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Densitometry(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}