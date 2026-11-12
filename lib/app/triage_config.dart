/// Tunable numbers for the triage engine. Change values here only.
class TriageConfig {
  TriageConfig._();

  // ---- Doctor matching weights (should add up to 1.0) ----
  static const double matchSpecialtyWeight = 0.5;
  static const double matchAvailabilityWeight = 0.2;
  static const double matchRatingWeight = 0.2;
  static const double matchFeeWeight = 0.1;

  /// Availability score for a doctor who does not sit today.
  static const double notAvailableTodayScore = 0.3;

  /// How many specialties are shown in the result.
  static const int topMatchCount = 3;

  /// Extra score for pediatrics when the patient is a child.
  static const double childPediatricsBoost = 0.8;

  /// Extra score for general medicine when the patient is a senior.
  static const double seniorGeneralBoost = 0.3;

  // ---- Urgency points (no red flag found) ----
  static const double severePoints = 3;
  static const double moderatePoints = 1;
  static const double longDurationPoints = 1; // more than a week
  static const double vulnerableAgePoints = 1; // child or senior, not mild
  static const double urgentHintPoints = 3; // chest pain, breathing, ...

  /// Points needed to show "See a doctor soon" instead of "Routine care".
  static const double urgentThreshold = 3;
}
