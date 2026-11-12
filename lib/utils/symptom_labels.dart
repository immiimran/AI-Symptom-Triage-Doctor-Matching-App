import '../models/symptom_input.dart';
import '../texts/app_texts.dart';

/// Readable labels for the symptom form values.
String ageLabel(AgeGroup value) {
  switch (value) {
    case AgeGroup.child:
      return t('age_child');
    case AgeGroup.adult:
      return t('age_adult');
    case AgeGroup.senior:
      return t('age_senior');
  }
}

String durationLabel(SymptomDuration value) {
  switch (value) {
    case SymptomDuration.underOneDay:
      return t('duration_lt_day');
    case SymptomDuration.oneToThreeDays:
      return t('duration_1_3');
    case SymptomDuration.fourToSevenDays:
      return t('duration_4_7');
    case SymptomDuration.overWeek:
      return t('duration_gt_week');
  }
}

String severityLabel(SymptomSeverity value) {
  switch (value) {
    case SymptomSeverity.mild:
      return t('severity_mild');
    case SymptomSeverity.moderate:
      return t('severity_moderate');
    case SymptomSeverity.severe:
      return t('severity_severe');
  }
}
