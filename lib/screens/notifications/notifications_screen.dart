import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../models/app_notification.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/notification_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_confirm_sheet.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/glass_scaffold.dart';
import 'notification_tile.dart';

/// The list behind the bell. Tap to read, swipe left to delete.
/// Notifications about appointments take the user to the Appointments tab:
/// this screen closes with the result 1 (the tab number).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _open(
    BuildContext context,
    NotificationProvider provider,
    AppNotification notification,
  ) async {
    await provider.markRead(notification.id);
    if (notification.isAboutAppointment && context.mounted) {
      Navigator.of(context).pop(1);
    }
  }

  Future<void> _clearAll(
    BuildContext context,
    NotificationProvider provider,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmSheet(
      context,
      title: t('notif_clear_title'),
      message: t('notif_clear_message'),
      confirmLabel: t('clear_all'),
      destructive: true,
      icon: Icons.delete_sweep_outlined,
    );
    if (!confirmed) return;

    await provider.clearAll();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t('notif_cleared'))));
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final provider = context.watch<NotificationProvider>();
    final doctors = context.watch<DoctorProvider>();
    final items = provider.items;

    return GlassScaffold(
      title: t('notifications_title'),
      actions: [
        if (provider.unreadCount > 0)
          GlassIconButton(
            icon: Icons.done_all_rounded,
            onTap: provider.markAllRead,
          ),
        if (items.isNotEmpty)
          GlassIconButton(
            icon: Icons.delete_sweep_outlined,
            onTap: () => _clearAll(context, provider),
          ),
      ],
      body: items.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = items[index];
                return FadeSlideIn(
                  key: ValueKey('fade_${notification.id}'),
                  delay: Duration(milliseconds: index < 6 ? index * 50 : 0),
                  child: Dismissible(
                    key: ValueKey(notification.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => provider.remove(notification.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 22),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.onGlass,
                      ),
                    ),
                    child: NotificationTile(
                      notification: notification,
                      doctors: doctors,
                      onTap: () => _open(context, provider, notification),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                size: 44,
                color: AppColors.sphereRose,
              ),
              const SizedBox(height: 12),
              Text(
                t('notif_empty'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onGlass,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t('notif_empty_hint'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onGlassMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
