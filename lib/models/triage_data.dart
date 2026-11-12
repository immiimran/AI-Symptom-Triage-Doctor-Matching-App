import '../texts/app_texts.dart';
import '../utils/text_normalizer.dart';

/// One symptom from symptoms.json: keywords and the specialties it points to.
class SymptomEntry {
  const SymptomEntry({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.keywords,
    required this.specialties,
    this.weight = 1.0,
    this.urgentHint = false,
  });

  final String id;
  final String nameEn;
  final String nameBn;

  /// Already normalized, ready for matching.
  final List<String> keywords;

  /// Specialty id -> strength between 0 and 1.
  final Map<String, double> specialties;
  final double weight;

  /// True for symptoms that raise urgency (chest pain, breathing, ...).
  final bool urgentHint;

  String get name =>
      AppTexts.current == AppLanguage.bn && nameBn.isNotEmpty ? nameBn : nameEn;

  factory SymptomEntry.fromJson(Map<String, dynamic> json) {
    final nameEn = json['name'] as String;
    return SymptomEntry(
      id: json['id'] as String,
      nameEn: nameEn,
      nameBn: (json['name_bn'] as String?) ?? nameEn,
      keywords: (json['keywords'] as List<dynamic>)
          .map((k) => TextNormalizer.normalize(k as String))
          .where((k) => k.isNotEmpty)
          .toList(),
      specialties: (json['specialties'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      urgentHint: (json['urgent_hint'] as bool?) ?? false,
    );
  }
}

/// An emergency pattern from red_flags.json.
class RedFlag {
  const RedFlag({
    required this.id,
    required this.always,
    required this.ifSevere,
  });

  final String id;

  /// Keywords that always mean emergency.
  final List<String> always;

  /// Keywords that mean emergency only when severity is "severe".
  final List<String> ifSevere;

  factory RedFlag.fromJson(Map<String, dynamic> json) {
    List<String> read(String key) => ((json[key] as List<dynamic>?) ?? const [])
        .map((k) => TextNormalizer.normalize(k as String))
        .where((k) => k.isNotEmpty)
        .toList();

    return RedFlag(
      id: json['id'] as String,
      always: read('always'),
      ifSevere: read('if_severe'),
    );
  }
}
