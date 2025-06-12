class MotorSkillsCalendar {
  final int? id;
  final String patientId;
  final DateTime skillDate; // Дата когда ребенок начал делать навык
  final String skillDescription; // Описание что начал делать
  final String? notes; // Дополнительные заметки
  final DateTime createdAt;
  final DateTime updatedAt;

  MotorSkillsCalendar({
    this.id,
    required this.patientId,
    required this.skillDate,
    required this.skillDescription,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'skill_date': skillDate.millisecondsSinceEpoch,
      'skill_description': skillDescription,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory MotorSkillsCalendar.fromMap(Map<String, dynamic> map) {
    return MotorSkillsCalendar(
      id: map['id'],
      patientId: map['patient_id'],
      skillDate: DateTime.fromMillisecondsSinceEpoch(map['skill_date']),
      skillDescription: map['skill_description'],
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  MotorSkillsCalendar copyWith({
    int? id,
    String? patientId,
    DateTime? skillDate,
    String? skillDescription,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MotorSkillsCalendar(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      skillDate: skillDate ?? this.skillDate,
      skillDescription: skillDescription ?? this.skillDescription,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
