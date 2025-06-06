class GMFCS {
  final int? id;
  final String patientId;
  final int level; // 1-5 уровни GMFCS
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  GMFCS({
    this.id,
    required this.patientId,
    required this.level,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'level': level,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory GMFCS.fromMap(Map<String, dynamic> map) {
    return GMFCS(
      id: map['id'],
      patientId: map['patient_id'],
      level: map['level'],
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  GMFCS copyWith({
    int? id,
    String? patientId,
    int? level,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GMFCS(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      level: level ?? this.level,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
