import 'package:intl/intl.dart';

import '../models/doctor_model.dart';
import '../texts/app_texts.dart';

/// Helpers for a doctor's chamber days.
class DoctorSchedule {
  DoctorSchedule._();

  static const List<String> _dayCodes = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  /// First date (today or later, within 14 days) when the doctor sits.
  static DateTime? nextAvailable(DoctorModel doctor, [DateTime? from]) {
    final start = from ?? DateTime.now();
    for (var i = 0; i < 14; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      if (doctor.chamberDays.contains(_dayCodes[date.weekday - 1])) {
        return date;
      }
    }
    return null;
  }

  /// "Today", "Tomorrow" or e.g. "Mon, Nov 16".
  static String label(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = date.difference(today).inDays;
    if (diff == 0) return t('today');
    if (diff == 1) return t('tomorrow');
    return DateFormat('EEE, MMM d').format(date);
  }
}
