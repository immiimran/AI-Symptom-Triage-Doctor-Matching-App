import '../texts/app_texts.dart';
import 'symptom_input.dart';

enum UrgencyLevel { emergency, urgent, routine }

/// One suggested specialty with its share of the total match.
class SpecialtyMatch {
  const SpecialtyMatch({
    required this.specialtyId,
    required this.score,
    required this.percent,
  });

  final String specialtyId;
  final double score;
  final int percent;

  Map<String, dynamic> toJson() => {
    'specialty_id': specialtyId,
    'score': score,
    'percent': percent,
  };

  factory SpecialtyMatch.fromJson(Map<String, dynamic> json) {
    return SpecialtyMatch(
      specialtyId: json['specialty_id'] as String,
      score: (json['score'] as num).toDouble(),
      percent: (json['percent'] as num).toInt(),
    );
  }
}

/// A symptom the engine recognised in the user's input.
class MatchedSymptom {
  const MatchedSymptom({
    required this.id,
    required this.nameEn,
    required this.nameBn,
  });

  final String id;
  final String nameEn;
  final String nameBn;

  String get name =>
      AppTexts.current == AppLanguage.bn && nameBn.isNotEmpty ? nameBn : nameEn;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': nameEn,
    'name_bn': nameBn,
  };

  factory MatchedSymptom.fromJson(Map<String, dynamic> json) {
    final nameEn = (json['name'] as String?) ?? '';
    return MatchedSymptom(
      id: json['id'] as String,
      nameEn: nameEn,
      nameBn: (json['name_bn'] as String?) ?? nameEn,
    );
  }
}

/// Full output of the triage engine.
class TriageResult {
  const TriageResult({
    required this.input,
    required this.matches,
    required this.urgency,
    required this.matchedSymptoms,
    required this.redFlagIds,
    required this.noMatch,
    required this.createdAt,
  });

  final SymptomInput input;

  /// Best match first. Never empty.
  final List<SpecialtyMatch> matches;
  final UrgencyLevel urgency;
  final List<MatchedSymptom> matchedSymptoms;
  final List<String> redFlagIds;

  /// True when no symptom could be recognised.
  final bool noMatch;
  final DateTime createdAt;

  SpecialtyMatch get topMatch => matches.first;
  bool get isEmergency => urgency == UrgencyLevel.emergency;

  Map<String, dynamic> toJson() => {
    'input': input.toJson(),
    'matches': matches.map((m) => m.toJson()).toList(),
    'urgency': urgency.name,
    'matched_symptoms': matchedSymptoms.map((s) => s.toJson()).toList(),
    'red_flag_ids': redFlagIds,
    'no_match': noMatch,
    'created_at': createdAt.toIso8601String(),
  };

  factory TriageResult.fromJson(Map<String, dynamic> json) {
    return TriageResult(
      input: SymptomInput.fromJson(json['input'] as Map<String, dynamic>),
      matches: (json['matches'] as List<dynamic>)
          .map((e) => SpecialtyMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
      urgency: UrgencyLevel.values.firstWhere(
        (u) => u.name == json['urgency'],
        orElse: () => UrgencyLevel.routine,
      ),
      matchedSymptoms:
          ((json['matched_symptoms'] as List<dynamic>?) ?? const [])
              .map((e) => MatchedSymptom.fromJson(e as Map<String, dynamic>))
              .toList(),
      redFlagIds: List<String>.from(
        (json['red_flag_ids'] as List<dynamic>?) ?? const [],
      ),
      noMatch: (json['no_match'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
