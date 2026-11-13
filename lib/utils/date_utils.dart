import 'package:intl/intl.dart';

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
}
