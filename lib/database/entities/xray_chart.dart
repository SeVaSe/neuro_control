class XrayChart {
  final int? id;
  final int orthopedicExaminationId;
  final String chartData; // JSON строка с данными графика
  final DateTime createdAt;

  XrayChart({
    this.id,
    required this.orthopedicExaminationId,
    required this.chartData,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orthopedic_examination_id': orthopedicExaminationId,
      'chart_data': chartData,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory XrayChart.fromMap(Map<String, dynamic> map) {
    return XrayChart(
      id: map['id'],
      orthopedicExaminationId: map['orthopedic_examination_id'],
      chartData: map['chart_data'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}
