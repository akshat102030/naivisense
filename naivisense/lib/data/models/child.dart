class TherapistAssignmentModel {
  final String therapistId;
  final String therapyType;
  final String? therapistName;
  final String? therapistPhone;

  const TherapistAssignmentModel({
    required this.therapistId,
    required this.therapyType,
    this.therapistName,
    this.therapistPhone,
  });

  factory TherapistAssignmentModel.fromJson(Map<String, dynamic> j) {
    final raw = j['therapist_id'];
    return TherapistAssignmentModel(
      therapistId:    raw is Map ? raw['_id'] as String? ?? '' : raw as String? ?? '',
      therapyType:    j['therapy_type'] as String? ?? '',
      therapistName:  raw is Map ? raw['name']  as String? : null,
      therapistPhone: raw is Map ? raw['phone'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'therapist_id': therapistId,
    'therapy_type': therapyType,
  };
}

class ChildModel {
  final String id;
  final String name;
  final int ageYears;
  final List<String> diagnosis;
  final String severity;
  final String centerId;
  final List<TherapistAssignmentModel> therapists;
  final String parentId;
  final String? parentName;
  final String? parentPhone;
  final String? avatarUrl;
  final Map<String, dynamic>? homeContext;

  // Backward-compat getters — point to the first assigned therapist
  String  get therapistId    => therapists.isNotEmpty ? therapists.first.therapistId    : '';
  String? get therapistName  => therapists.isNotEmpty ? therapists.first.therapistName  : null;
  String? get therapistPhone => therapists.isNotEmpty ? therapists.first.therapistPhone : null;

  const ChildModel({
    required this.id,
    required this.name,
    required this.ageYears,
    required this.diagnosis,
    required this.severity,
    required this.centerId,
    required this.therapists,
    required this.parentId,
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

    final parentRaw = j['parent_id'];

    final therapistsList = (j['therapists'] as List?)
        ?.map((e) => TherapistAssignmentModel.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [];

    return ChildModel(
      id:          j['_id'] as String? ?? '',
      name:        j['name'] as String? ?? '',
      ageYears:    (j['age_years'] as int?) ?? _ageFromDob(j['dob'] as String?),
      diagnosis:   diagList,
      severity:    j['severity'] as String? ?? 'mild',
      centerId:    j['center_id'] as String? ?? '',
      therapists:  therapistsList,
      parentId:    _extractId(parentRaw),
      parentName:  _extractName(parentRaw),
      parentPhone: _extractPhone(parentRaw),
      avatarUrl:   j['avatar_url'] as String?,
      homeContext: j['home_context'] as Map<String, dynamic>?,
    );
  }
}
