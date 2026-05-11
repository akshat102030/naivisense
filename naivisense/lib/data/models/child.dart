class ChildModel {
  final String id;
  final String name;
  final int ageYears;
  final List<String> diagnosis;
  final String severity;
  final String centerId;
  final String therapistId;
  final String parentId;
  final String? therapistName;
  final String? therapistPhone;
  final String? parentName;
  final String? parentPhone;
  final String? avatarUrl;
  final Map<String, dynamic>? homeContext;

  const ChildModel({
    required this.id,
    required this.name,
    required this.ageYears,
    required this.diagnosis,
    required this.severity,
    required this.centerId,
    required this.therapistId,
    required this.parentId,
    this.therapistName,
    this.therapistPhone,
    this.parentName,
    this.parentPhone,
    this.avatarUrl,
    this.homeContext,
  });

  static int _ageFromDob(String? dobStr) {
    if (dobStr == null) return 0;
    try {
      final dob = DateTime.parse(dobStr);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) age--;
      return age < 0 ? 0 : age;
    } catch (_) { return 0; }
  }

  /// Handles both populated ({_id, name, phone}) and raw string ID.
  static String _extractId(dynamic raw) {
    if (raw == null) return '';
    if (raw is Map) return raw['_id'] as String? ?? '';
    return raw as String? ?? '';
  }

  static String? _extractName(dynamic raw) {
    if (raw is Map) return raw['name'] as String?;
    return null;
  }

  static String? _extractPhone(dynamic raw) {
    if (raw is Map) return raw['phone'] as String?;
    return null;
  }

  factory ChildModel.fromJson(Map<String, dynamic> j) {
    final diag = j['diagnosis'];
    final diagList = diag is List
        ? diag.map((e) => e.toString()).toList()
        : [diag.toString()];

    final therapistRaw = j['therapist_id'];
    final parentRaw    = j['parent_id'];

    return ChildModel(
      id:             j['_id'] as String? ?? '',
      name:           j['name'] as String? ?? '',
      ageYears:       (j['age_years'] as int?) ?? _ageFromDob(j['dob'] as String?),
      diagnosis:      diagList,
      severity:       j['severity'] as String? ?? 'mild',
      centerId:       j['center_id'] as String? ?? '',
      therapistId:    _extractId(therapistRaw),
      parentId:       _extractId(parentRaw),
      therapistName:  _extractName(therapistRaw),
      therapistPhone: _extractPhone(therapistRaw),
      parentName:     _extractName(parentRaw),
      parentPhone:    _extractPhone(parentRaw),
      avatarUrl:      j['avatar_url'] as String?,
      homeContext:    j['home_context'] as Map<String, dynamic>?,
    );
  }
}
