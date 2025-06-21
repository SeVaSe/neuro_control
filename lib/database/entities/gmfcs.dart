class GMFCS {
  final String patientId;
  final int level;

  GMFCS({
    required this.patientId,
    required this.level,
  });

  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'level': level,
    };
  }

  factory GMFCS.fromMap(Map<String, dynamic> map) {
    return GMFCS(
      patientId: map['patient_id'],
      level: map['level'],
    );
  }

  GMFCS copyWith({
    String? patientId,
    int? level,
  }) {
    return GMFCS(
      patientId: patientId ?? this.patientId,
      level: level ?? this.level,
    );
  }
}
