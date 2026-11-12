import '../app/triage_config.dart';
import '../models/doctor_filter.dart';
import '../models/doctor_model.dart';
import '../utils/text_normalizer.dart';

/// Filters, searches and ranks doctors.
/// match score = specialty x 0.5 + availability x 0.2 + rating x 0.2
/// + fee x 0.1 (weights are in TriageConfig).
class DoctorMatchingService {
  List<DoctorModel> apply({
    required List<DoctorModel> doctors,
    required String query,
    required String? specialtyId,
    required DoctorFilter filter,
    required DoctorSort sort,
    required Map<String, int> specialtyPercents,
    required double Function(DoctorModel) ratingOf,
    required String Function(String) specialtyNameOf,
  }) {
    final list = doctors.where((d) {
      if (specialtyId != null && d.specialtyId != specialtyId) return false;
      if (filter.availableToday && !d.isAvailableToday) return false;
      if (filter.gender != null && d.gender != filter.gender) return false;
      if (ratingOf(d) < filter.minRating) return false;
      if (filter.maxFee != null && d.fee > filter.maxFee!) return false;
      return _matchesQuery(d, query, specialtyNameOf);
    }).toList();

    switch (sort) {
      case DoctorSort.bestMatch:
        final fees = list.map((d) => d.fee.toDouble()).toList();
        final minFee = fees.isEmpty
            ? 0.0
            : fees.reduce((a, b) => a < b ? a : b);
        final maxFee = fees.isEmpty
            ? 0.0
            : fees.reduce((a, b) => a > b ? a : b);
        final scores = {
          for (final d in list)
            d.id: score(
              doctor: d,
              specialtyPercent: specialtyPercents[d.specialtyId] ?? 0,
              rating: ratingOf(d),
              minFee: minFee,
              maxFee: maxFee,
            ),
        };
        list.sort((a, b) => scores[b.id]!.compareTo(scores[a.id]!));
      case DoctorSort.topRated:
        list.sort((a, b) => ratingOf(b).compareTo(ratingOf(a)));
      case DoctorSort.lowestFee:
        list.sort((a, b) => a.fee.compareTo(b.fee));
      case DoctorSort.mostExperienced:
        list.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
    }
    return list;
  }

  /// Match score between 0 and 1.
  double score({
    required DoctorModel doctor,
    required int specialtyPercent,
    required double rating,
    required double minFee,
    required double maxFee,
  }) {
    final specialty = specialtyPercent / 100;
    final availability = doctor.isAvailableToday
        ? 1.0
        : TriageConfig.notAvailableTodayScore;
    final ratingScore = (rating / 5).clamp(0.0, 1.0);
    final feeScore = maxFee == minFee
        ? 1.0
        : 1 - (doctor.fee - minFee) / (maxFee - minFee);

    return specialty * TriageConfig.matchSpecialtyWeight +
        availability * TriageConfig.matchAvailabilityWeight +
        ratingScore * TriageConfig.matchRatingWeight +
        feeScore * TriageConfig.matchFeeWeight;
  }

  bool _matchesQuery(
    DoctorModel doctor,
    String query,
    String Function(String) specialtyNameOf,
  ) {
    final q = TextNormalizer.normalize(query);
    if (q.isEmpty) return true;

    final haystack = TextNormalizer.normalize(
      [
        doctor.nameEn,
        doctor.nameBn,
        doctor.degrees,
        doctor.hospitalEn,
        doctor.hospitalBn,
        specialtyNameOf(doctor.specialtyId),
      ].join(' '),
    );

    return q.split(' ').every(haystack.contains);
  }
}
