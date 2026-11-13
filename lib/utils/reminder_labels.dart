import '../app/constants.dart';
import '../texts/app_texts.dart';

/// Readable label for a reminder choice (minutes before, or null for none).
String reminderLabel(int? minutes) {
  if (minutes == null) return t('reminder_off');
  if (minutes == AppConstants.testReminderMinutes) return t('reminder_test');
  if (minutes == 1440) return t('reminder_1_day');
  if (minutes == 180) return t('reminder_3_hours');
  if (minutes == 60) return t('reminder_1_hour');
  return '$minutes min';
}
