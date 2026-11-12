import '../texts/app_texts.dart';

enum DoctorSort { bestMatch, topRated, lowestFee, mostExperienced }

extension DoctorSortLabel on DoctorSort {
  String get label {
    switch (this) {
      case DoctorSort.bestMatch:
        return t('sort_best_match');
      case DoctorSort.topRated:
        return t('sort_top_rated');
      case DoctorSort.lowestFee:
        return t('sort_lowest_fee');
      case DoctorSort.mostExperienced:
        return t('sort_experience');
    }
  }
}

/// Filters for the doctor list.
class DoctorFilter {
  const DoctorFilter({
    this.availableToday = false,
    this.gender,
    this.minRating = 0,
    this.maxFee,
  });

  static const Object _unset = Object();
  static const DoctorFilter none = DoctorFilter();

  final bool availableToday;

  /// 'male', 'female' or null for any.
  final String? gender;
  final double minRating;
  final int? maxFee;

  bool get isActive =>
      availableToday || gender != null || minRating > 0 || maxFee != null;

  DoctorFilter copyWith({
    bool? availableToday,
    Object? gender = _unset,
    double? minRating,
    Object? maxFee = _unset,
  }) {
    return DoctorFilter(
      availableToday: availableToday ?? this.availableToday,
      gender: identical(gender, _unset) ? this.gender : gender as String?,
      minRating: minRating ?? this.minRating,
      maxFee: identical(maxFee, _unset) ? this.maxFee : maxFee as int?,
    );
  }
}
