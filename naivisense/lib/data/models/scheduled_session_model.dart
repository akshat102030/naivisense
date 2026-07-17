class ScheduledSessionModel {
  final String therapyType;
  final List<String> days;
  final String fromTime;
  final String toTime;

  const ScheduledSessionModel({
    required this.therapyType,
    required this.days,
    required this.fromTime,
    required this.toTime,
  });

  factory ScheduledSessionModel.fromJson(Map<String, dynamic> json) {
    return ScheduledSessionModel(
      therapyType: json['therapy_type'] ?? '',
      days: List<String>.from(json['days'] ?? const []),
      fromTime: json['from_time'] ?? '',
      toTime: json['to_time'] ?? '',
    );
  }

  String get daysLabel => days.join(', ');

  String get timeLabel => '$fromTime - $toTime';
}
