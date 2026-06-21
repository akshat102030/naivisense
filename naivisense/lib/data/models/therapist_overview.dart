class TherapistChildSummary {
  final String id;
  final String name;
  final List<String> diagnosis;
  final String severity;
  final String therapyType;

  const TherapistChildSummary({
    required this.id,
    required this.name,
    required this.diagnosis,
    required this.severity,
    required this.therapyType,
  });

  factory TherapistChildSummary.fromJson(Map<String, dynamic> j) =>
      TherapistChildSummary(
        id:          (j['_id'] ?? j['id']) as String? ?? '',
        name:        j['name'] as String? ?? '',
        diagnosis:   (j['diagnosis'] as List?)?.map((e) => e.toString()).toList() ?? [],
        severity:    j['severity'] as String? ?? 'mild',
        therapyType: j['therapy_type'] as String? ?? '',
      );
}

class TherapistOverview {
  final String id;
  final String name;
  final String phone;
  final List<String> specialties;
  final List<String> therapyMethods;
  final String qualification;
  final int yearsExperience;
  final List<TherapistChildSummary> children;

  const TherapistOverview({
    required this.id,
    required this.name,
    required this.phone,
    required this.specialties,
    required this.therapyMethods,
    required this.qualification,
    required this.yearsExperience,
    required this.children,
  });

  factory TherapistOverview.fromJson(Map<String, dynamic> j) => TherapistOverview(
        id:              (j['_id'] ?? j['id']) as String? ?? '',
        name:            j['name'] as String? ?? '',
        phone:           j['phone'] as String? ?? '',
        specialties:     (j['specialties'] as List?)?.map((e) => e.toString()).toList() ?? [],
        therapyMethods:  (j['therapy_methods'] as List?)?.map((e) => e.toString()).toList() ?? [],
        qualification:   j['qualification'] as String? ?? '',
        yearsExperience: (j['years_experience'] as num?)?.toInt() ?? 0,
        children:        (j['children'] as List?)
                ?.map((e) => TherapistChildSummary.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
