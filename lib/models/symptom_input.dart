enum AgeGroup { child, adult, senior }

enum SymptomDuration { underOneDay, oneToThreeDays, fourToSevenDays, overWeek }

enum SymptomSeverity { mild, moderate, severe }

/// Everything the user entered on the symptom screen.
/// It is passed to the analysis step (triage engine).
class SymptomInput {
  const SymptomInput({
    required this.text,
    this.ageGroup = AgeGroup.adult,
    this.duration = SymptomDuration.oneToThreeDays,
    this.severity = SymptomSeverity.moderate,
    this.symptomIds = const [],
  });

  final String text;
  final AgeGroup ageGroup;
  final SymptomDuration duration;
  final SymptomSeverity severity;
  final List<String> symptomIds;

  Map<String, dynamic> toJson() => {
    'text': text,
    'age_group': ageGroup.name,
    'duration': duration.name,
    'severity': severity.name,
    'symptom_ids': symptomIds,
  };

  factory SymptomInput.fromJson(Map<String, dynamic> json) {
    return SymptomInput(
      text: (json['text'] as String?) ?? '',
      ageGroup: _byName(AgeGroup.values, json['age_group'], AgeGroup.adult),
      duration: _byName(
        SymptomDuration.values,
        json['duration'],
        SymptomDuration.oneToThreeDays,
      ),
      severity: _byName(
        SymptomSeverity.values,
        json['severity'],
        SymptomSeverity.moderate,
      ),
      symptomIds: List<String>.from(
        (json['symptom_ids'] as List<dynamic>?) ?? const [],
      ),
    );
  }

  static T _byName<T extends Enum>(List<T> values, Object? name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }

  @override
  String toString() =>
      'SymptomInput(text: $text, age: ${ageGroup.name}, '
      'duration: ${duration.name}, severity: ${severity.name}, '
      'ids: $symptomIds)';
}
