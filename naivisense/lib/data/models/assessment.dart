class DomainScores {
  final double attention;
  final double behavioral;
  final double socialCommunication;
  final double receptiveLanguage;
  final double expressiveLanguage;
  final double speechProduction;
  final double imitation;
  final double visualPerception;
  final double fineMotor;
  final double grossMotor;
  final double sensory;
  final double adl;
  final double academics;
  final double cognitive;
  final double emotionalRegulation;

  const DomainScores({
    this.attention = 0,
    this.behavioral = 0,
    this.socialCommunication = 0,
    this.receptiveLanguage = 0,
    this.expressiveLanguage = 0,
    this.speechProduction = 0,
    this.imitation = 0,
    this.visualPerception = 0,
    this.fineMotor = 0,
    this.grossMotor = 0,
    this.sensory = 0,
    this.adl = 0,
    this.academics = 0,
    this.cognitive = 0,
    this.emotionalRegulation = 0,
  });

  factory DomainScores.fromJson(Map<String, dynamic> j) => DomainScores(
    attention: (j['attention'] as num?)?.toDouble() ?? 0,
    behavioral: (j['behavioral'] as num?)?.toDouble() ?? 0,
    socialCommunication: (j['social_communication'] as num?)?.toDouble() ?? 0,
    receptiveLanguage: (j['receptive_language'] as num?)?.toDouble() ?? 0,
    expressiveLanguage: (j['expressive_language'] as num?)?.toDouble() ?? 0,
    speechProduction: (j['speech_production'] as num?)?.toDouble() ?? 0,
    imitation: (j['imitation'] as num?)?.toDouble() ?? 0,
    visualPerception: (j['visual_perception'] as num?)?.toDouble() ?? 0,
    fineMotor: (j['fine_motor'] as num?)?.toDouble() ?? 0,
    grossMotor: (j['gross_motor'] as num?)?.toDouble() ?? 0,
    sensory: (j['sensory'] as num?)?.toDouble() ?? 0,
    adl: (j['adl'] as num?)?.toDouble() ?? 0,
    academics: (j['academics'] as num?)?.toDouble() ?? 0,
    cognitive: (j['cognitive'] as num?)?.toDouble() ?? 0,
    emotionalRegulation: (j['emotional_regulation'] as num?)?.toDouble() ?? 0,
  );

  Map<String, double> toKeyedMap() => {
    'attention': attention,
    'behavioral': behavioral,
    'social_communication': socialCommunication,
    'receptive_language': receptiveLanguage,
    'expressive_language': expressiveLanguage,
    'speech_production': speechProduction,
    'imitation': imitation,
    'visual_perception': visualPerception,
    'fine_motor': fineMotor,
    'gross_motor': grossMotor,
    'sensory': sensory,
    'adl': adl,
    'academics': academics,
    'cognitive': cognitive,
    'emotional_regulation': emotionalRegulation,
  };
}

class AssessmentSnapshot {
  final String type;
  final DateTime date;
  final String assessedBy;
  final bool isComplete;
  final DomainScores domainScores;
  final double overallScorePct;
  final String riskLevel;
  final double developmentalQuotient;
  final String generalNotes;
  final Map<String, dynamic>? domainData;

  const AssessmentSnapshot({
    required this.type,
    required this.date,
    required this.assessedBy,
    required this.isComplete,
    required this.domainScores,
    required this.overallScorePct,
    required this.riskLevel,
    required this.developmentalQuotient,
    required this.generalNotes,
    this.domainData,
  });

  factory AssessmentSnapshot.fromJson(Map<String, dynamic> j) {
    return AssessmentSnapshot(
      type: j['type'] ?? 'initial',
      date: j['date'] != null
          ? DateTime.tryParse(j['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      assessedBy: j['assessed_by'] ?? '',
      isComplete: j['is_complete'] ?? false,
      domainScores: DomainScores.fromJson(
        Map<String, dynamic>.from(j['domain_scores'] ?? {}),
      ),
      overallScorePct: (j['overall_score_pct'] as num?)?.toDouble() ?? 0,
      riskLevel: j['risk_level'] ?? 'amber',
      developmentalQuotient:
          (j['developmental_quotient'] as num?)?.toDouble() ?? 0,
      generalNotes: j['general_notes'] ?? '',
      domainData: j['domain_data'] != null
          ? Map<String, dynamic>.from(j['domain_data'])
          : null,
    );
  }
}

class AssessmentModel {
  final String id;
  final String childId;

  final AssessmentSnapshot? initial;
  final AssessmentSnapshot? latest;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AssessmentModel({
    required this.id,
    required this.childId,
    this.initial,
    this.latest,
    this.createdAt,
    this.updatedAt,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> j) {
    return AssessmentModel(
      id: j['_id'] ?? '',
      childId: j['child_id'] ?? '',
      initial: j['initial'] != null
          ? AssessmentSnapshot.fromJson(Map<String, dynamic>.from(j['initial']))
          : null,
      latest: j['latest'] != null
          ? AssessmentSnapshot.fromJson(Map<String, dynamic>.from(j['latest']))
          : null,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString())
          : null,
      updatedAt: j['updated_at'] != null
          ? DateTime.tryParse(j['updated_at'].toString())
          : null,
    );
  }

  bool get hasInitial => initial != null;

  bool get hasLatest => latest != null;

  AssessmentSnapshot get display => latest ?? initial ?? _emptySnapshot;
  String get displayType => display.type;
  DateTime get displayDate => display.date;
  String get displayRiskLevel => display.riskLevel;
  double get displayOverallScore => display.overallScorePct;
  double get displayDevelopmentalQuotient => display.developmentalQuotient;
  DomainScores get displayDomainScores => display.domainScores;
  String get displayGeneralNotes => display.generalNotes;
  Map<String, dynamic>? get prefillData =>
      latest?.domainData ?? initial?.domainData;

  static final AssessmentSnapshot _emptySnapshot = AssessmentSnapshot(
    type: 'initial',
    date: DateTime.fromMillisecondsSinceEpoch(0),
    assessedBy: '',
    isComplete: false,
    domainScores: const DomainScores(),
    overallScorePct: 0,
    riskLevel: 'amber',
    developmentalQuotient: 0,
    generalNotes: '',
    domainData: null,
  );
}
