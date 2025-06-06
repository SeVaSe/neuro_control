class Salivation {
  final int? id;
  final String patientId;
  final int complicationScore;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Salivation({
    this.id,
    required this.patientId,
    required this.complicationScore,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'complication_score': complicationScore,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Salivation.fromMap(Map<String, dynamic> map) {
    return Salivation(
      id: map['id'],
      patientId: map['patient_id'],
      complicationScore: map['complication_score'],
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  Salivation copyWith({
    int? id,
    String? patientId,
    int? complicationScore,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Salivation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      complicationScore: complicationScore ?? this.complicationScore,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
