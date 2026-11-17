import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../models/app_notification.dart';
import '../../providers/doctor_provider.dart';
import '../../texts/app_texts.dart';
import '../../utils/date_utils.dart';
import '../../utils/doctor_schedule.dart';
import '../../utils/reminder_labels.dart';
import '../../utils/time_ago.dart';
import '../../widgets/glass_card.dart';

/// One row in the notification list.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.doctors,
    required this.onTap,
  });

  final AppNotification notification;
  final DoctorProvider doctors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final view = _describe(notification, doctors);
    final unread = !notification.isRead;

    return GlassCard(
      blur: false,
      radius: 18,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: view.color.withValues(alpha: 0.22),
              border: Border.all(color: view.color.withValues(alpha: 0.6)),
            ),
            child: Icon(view.icon, color: AppColors.onGlass, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        view.title,
                        style: TextStyle(
                          color: unread
                              ? AppColors.onGlass
                              : AppColors.onGlassMuted,
                          fontSize: 15,
                          fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.sphereRose,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (view.body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    view.body,
                    style: TextStyle(
                      color: unread ? AppColors.onGlass : AppColors.onGlassMuted,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  timeAgo(notification.createdAt),
                  style: const TextStyle(
                    color: AppColors.onGlassMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _View {
  const _View(this.icon, this.color, this.title, this.body);

  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

/// Builds the icon, color and words for a notification, in the current
/// language.
_View _describe(AppNotification n, DoctorProvider doctors) {
  final doctor = n.doctorId == null ? null : doctors.doctorById(n.doctorId!);
  final who = doctor?.name ?? '';
  final when = n.dateTime == null
      ? ''
      : '${AppDateUtils.fullDate(n.dateTime!)}, ${AppDateUtils.time(n.dateTime!)}';
  final serial = n.serial == null ? '' : '${t('serial')} #${n.serial}';

  String join(List<String> parts) => parts.where((p) => p.isNotEmpty).join(' · ');

  switch (n.type) {
    case NotificationType.welcome:
      return _View(Icons.favorite_rounded, AppColors.sphereRose,
          t('notif_welcome_title'), t('notif_welcome_body'));
    case NotificationType.booked:
      return _View(Icons.check_circle_rounded, AppColors.success,
          t('notif_booked_title'), join([who, when, serial]));
    case NotificationType.cancelled:
      return _View(Icons.event_busy_rounded, AppColors.error,
          t('notif_cancelled_title'), join([who, when]));
    case NotificationType.rescheduled:
      return _View(Icons.event_repeat_rounded, AppColors.urgent,
          t('notif_rescheduled_title'), join([who, when, serial]));
    case NotificationType.reminderSet:
      return _View(
          Icons.notifications_active_rounded,
          AppColors.sphereRose,
          t('notif_reminder_title'),
          join([reminderLabel(n.reminderMinutes), who, when]));
    case NotificationType.soon:
      final day = n.dateTime == null ? '' : DoctorSchedule.label(n.dateTime!);
      final time = n.dateTime == null ? '' : AppDateUtils.time(n.dateTime!);
      return _View(
          Icons.access_time_filled_rounded,
          AppColors.urgent,
          t('notif_soon_title'),
          join(['$day $time'.trim(), who, doctor?.hospital ?? '', serial]));
    case NotificationType.tip:
      return _View(Icons.lightbulb_rounded, AppColors.star,
          t('notif_tip_title'), t('tip_daily_${n.tipIndex ?? 0}'));
  }
}