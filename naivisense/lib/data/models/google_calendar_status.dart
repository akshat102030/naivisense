class GoogleCalendarStatus {
  final bool connected;
  final String? email;

  const GoogleCalendarStatus({required this.connected, this.email});

  factory GoogleCalendarStatus.fromJson(Map<String, dynamic> json) {
    return GoogleCalendarStatus(
      connected: json['connected'] ?? false,
      email: json['email'],
    );
  }
}
