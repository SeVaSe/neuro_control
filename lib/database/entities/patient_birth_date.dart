// lib/database/entities/patient_birth_date.dart

class PatientBirthDate {
  final String patientId;
  final DateTime birthDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PatientBirthDate({
    required this.patientId,
    required this.birthDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PatientBirthDate.fromMap(Map<String, dynamic> map) {
    return PatientBirthDate(
      patientId: map['patient_id'] as String,
      birthDate: DateTime.fromMillisecondsSinceEpoch(map['birth_date'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'birth_date': birthDate.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  PatientBirthDate copyWith({
    String? patientId,
    DateTime? birthDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientBirthDate(
      patientId: patientId ?? this.patientId,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PatientBirthDate &&
        other.patientId == patientId &&
        other.birthDate == birthDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return patientId.hashCode ^
    birthDate.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'PatientBirthDate(patientId: $patientId, birthDate: $birthDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}