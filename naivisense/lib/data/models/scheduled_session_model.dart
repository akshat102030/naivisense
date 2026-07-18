class ScheduledSessionModel {
  final String therapyType;
  final List<int> days;
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
      therapyType: json['therapyType'] ?? '',
      days: (json['days'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      fromTime: json['fromTime'] ?? '',
      toTime: json['toTime'] ?? '',
    );
  }

  static const List<String> _weekDays = [
    '',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  String get daysLabel => days.map((d) => _weekDays[d]).join(', ');

  String get timeLabel => '$fromTime - $toTime';
}
