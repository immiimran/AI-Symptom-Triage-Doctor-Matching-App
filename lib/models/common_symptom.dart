import '../texts/app_texts.dart';

/// A quick-pick symptom chip. Loaded from common_symptoms.json.
class CommonSymptom {
  const CommonSymptom({required this.id, required this.en, required this.bn});

  final String id;
  final String en;
  final String bn;

  /// Label in the currently selected language.
  String get label =>
      AppTexts.current == AppLanguage.bn && bn.isNotEmpty ? bn : en;

  factory CommonSymptom.fromJson(Map<String, dynamic> json) {
    return CommonSymptom(
      id: json['id'] as String,
      en: json['en'] as String,
      bn: (json['bn'] as String?) ?? '',
    );
  }
}
