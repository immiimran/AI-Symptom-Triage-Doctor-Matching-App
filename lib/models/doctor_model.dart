import '../texts/app_texts.dart';

/// A doctor. Loaded from doctors_seed.json (or Firestore later).
class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.degrees,
    required this.specialtyId,
    required this.hospitalEn,
    required this.hospitalBn,
    required this.addressEn,
    required this.addressBn,
    required this.phone,
    required this.chamberDays,
    required this.chamberTime,
    required this.fee,
    required this.experienceYears,
    required this.patientCount,
    required this.rating,
    required this.reviewCount,
    required this.gender,
    required this.photo,
    required this.aboutEn,
    required this.aboutBn,
  });

  static const List<String> _dayCodes = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  final String id;
  final String nameEn;
  final String nameBn;
  final String degrees;
  final String specialtyId;
  final String hospitalEn;
  final String hospitalBn;
  final String addressEn;
  final String addressBn;
  final String phone;

  /// Day codes: sat, sun, mon, tue, wed, thu, fri.
  final List<String> chamberDays;
  final String chamberTime;
  final int fee;
  final int experienceYears;
  final int patientCount;
  final double rating;
  final int reviewCount;
  final String gender;

  /// Asset path of the photo, or empty to show the initials avatar.
  final String photo;
  final String aboutEn;
  final String aboutBn;

  bool get _isBangla => AppTexts.current == AppLanguage.bn;

  String _pick(String en, String bn) => _isBangla && bn.isNotEmpty ? bn : en;

  String get name => _pick(nameEn, nameBn);
  String get hospital => _pick(hospitalEn, hospitalBn);
  String get address => _pick(addressEn, addressBn);
  String get about => _pick(aboutEn, aboutBn);

  /// Days the doctor sits, e.g. "Sat, Sun, Mon".
  String get chamberDaysLabel =>
      chamberDays.map((day) => t('day_$day')).join(', ');

  bool get isAvailableToday {
    final today = _dayCodes[DateTime.now().weekday - 1];
    return chamberDays.contains(today);
  }

  /// Used to sort "Popular Doctors".
  double get popularityScore => rating * reviewCount;

  /// First letters of the name (without "Dr."), for the initials avatar.
  String get initials {
    final cleaned = name
        .replaceFirst(RegExp(r'^(Dr\.?|ডা\.?)\s*', caseSensitive: false), '')
        .trim();
    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    String first(String text) => String.fromCharCode(text.runes.first);
    final letters =
        first(parts.first) + (parts.length > 1 ? first(parts[1]) : '');
    return letters.toUpperCase();
  }

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      nameEn: json['name'] as String,
      nameBn: (json['name_bn'] as String?) ?? '',
      degrees: (json['degrees'] as String?) ?? '',
      specialtyId: json['specialty'] as String,
      hospitalEn: (json['hospital'] as String?) ?? '',
      hospitalBn: (json['hospital_bn'] as String?) ?? '',
      addressEn: (json['address'] as String?) ?? '',
      addressBn: (json['address_bn'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      chamberDays: List<String>.from(json['chamber_days'] as List<dynamic>),
      chamberTime: (json['chamber_time'] as String?) ?? '',
      fee: (json['fee'] as num?)?.toInt() ?? 0,
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      patientCount: (json['patient_count'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      gender: (json['gender'] as String?) ?? '',
      photo: (json['photo'] as String?) ?? '',
      aboutEn: (json['about'] as String?) ?? '',
      aboutBn: (json['about_bn'] as String?) ?? '',
    );
  }
}
