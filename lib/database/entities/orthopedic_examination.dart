class OrthopedicExamination {
  final int? id;
  final String patientId;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrthopedicExamination({
    this.id,
    required this.patientId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory OrthopedicExamination.fromMap(Map<String, dynamic> map) {
    return OrthopedicExamination(
      id: map['id'],
      patientId: map['patient_id'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  OrthopedicExamination copyWith({
    int? id,
    String? patientId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrthopedicExamination(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
