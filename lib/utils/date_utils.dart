import 'package:intl/intl.dart';

import '../texts/app_texts.dart';

/// Date and time formatting helpers.
class AppDateUtils {
  AppDateUtils._();

  /// e.g. "Nov 12"
  static String shortDate(DateTime date) => DateFormat('MMM d').format(date);

  /// e.g. "Thu, Nov 12"
  static String fullDate(DateTime date) =>
      DateFormat('EEE, MMM d').format(date);

  /// e.g. "5:00 PM"
  static String time(DateTime date) => DateFormat('h:mm a').format(date);

  /// "Today", "Yesterday" or e.g. "Thu, Nov 12" (for past dates).
  static String dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return t('today');
    if (diff == 1) return t('yesterday');
    return fullDate(date);
  }
}
