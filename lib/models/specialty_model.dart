import '../texts/app_texts.dart';

/// A medical specialty (cardiology, ENT, ...). Loaded from specialties.json.
class SpecialtyModel {
  const SpecialtyModel({
    required this.id,
    required this.nameEn,
    required this.nameBn,
  });

  final String id;
  final String nameEn;
  final String nameBn;

  /// Name in the currently selected language.
  String get name => AppTexts.current == AppLanguage.bn ? nameBn : nameEn;

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    final nameEn = json['name'] as String;
    return SpecialtyModel(
      id: json['id'] as String,
      nameEn: nameEn,
      nameBn: (json['name_bn'] as String?) ?? nameEn,
    );
  }
}
