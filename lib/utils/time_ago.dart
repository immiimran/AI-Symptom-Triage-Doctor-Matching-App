import '../texts/app_texts.dart';
import 'date_utils.dart';

/// "Just now", "5 min ago", "2 h ago", "Yesterday" or a date.
String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return t('time_now');
  if (diff.inMinutes < 60) return '${diff.inMinutes} ${t('time_min_ago')}';
  if (diff.inHours < 24) return '${diff.inHours} ${t('time_hour_ago')}';
  return AppDateUtils.dayLabel(time);
}
