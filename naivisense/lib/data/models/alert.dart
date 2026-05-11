class AlertModel {
  final String id;
  final String childId;
  final String raisedBy;
  final String type;        // fever|regression|aggression|seizure|sleep_issue|injury|emotional_stress|other
  final String description;
  final String severity;    // low | medium | high
  final String status;      // open | seen | resolved
  final DateTime createdAt;

  const AlertModel({
    required this.id,
    required this.childId,
    required this.raisedBy,
    required this.type,
    required this.description,
    required this.severity,
    required this.status,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> j) => AlertModel(
        id:          j['_id'] as String? ?? '',
        childId:     j['child_id'] as String? ?? '',
        raisedBy:    j['raised_by'] as String? ?? '',
        type:        j['type'] as String? ?? 'other',
        description: j['description'] as String? ?? '',
        severity:    j['severity'] as String? ?? 'low',
        status:      j['status'] as String? ?? 'open',
        createdAt:   DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  String get typeLabel => switch (type) {
    'fever'            => 'Fever',
    'regression'       => 'Regression',
    'aggression'       => 'Aggression',
    'seizure'          => 'Seizure',
    'sleep_issue'      => 'Sleep Issue',
    'injury'           => 'Injury',
    'emotional_stress' => 'Emotional Stress',
    _                  => 'Other',
  };
}
