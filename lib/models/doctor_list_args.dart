import 'triage_result.dart';

/// Arguments for the doctor list screen.
/// Pass the triage matches so doctors are ranked by match score.
class DoctorListArgs {
  const DoctorListArgs({this.specialtyId, this.matches = const []});

  final String? specialtyId;
  final List<SpecialtyMatch> matches;
}
