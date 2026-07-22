class ScheduledSessionModel {
  final String therapyType;
  final List<int> days;
  final String fromTime;
  final String toTime;

  // NEW
  final bool hasPendingAttendance;
  final DateTime? pendingAttendanceDate;

  const ScheduledSessionModel({
    required this.therapyType,
    required this.days,
    required this.fromTime,
    required this.toTime,
    required this.hasPendingAttendance,
    this.pendingAttendanceDate,
  });

  factory ScheduledSessionModel.fromJson(Map<String, dynamic> json) {
    return ScheduledSessionModel(
      therapyType: json['therapyType'] ?? '',
      days: (json['days'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      fromTime: json['fromTime'] ?? '',
      toTime: json['toTime'] ?? '',

      // NEW
      hasPendingAttendance: json['hasPendingAttendance'] ?? false,
      pendingAttendanceDate: json['pendingAttendanceDate'] != null
          ? DateTime.parse(json['pendingAttendanceDate'])
          : null,
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
