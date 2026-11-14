import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/constants.dart';
import '../../providers/language_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/triage_provider.dart';
import '../../services/notification_service.dart';
import '../../texts/app_texts.dart';
import '../../utils/reminder_labels.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_chip.dart';
import '../../widgets/glass_confirm_sheet.dart';
import '../../widgets/glass_info_sheet.dart';
import '../../widgets/glass_menu_row.dart';
import '../../widgets/glass_scaffold.dart';

/// Settings: language, default reminder, privacy and safety, your data, about.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// null = no default reminder, then the options from AppConstants.
  static final List<int?> _reminderOptions = <int?>[
    null,
    ...AppConstants.reminderOptions,
  ];

  void _showMessage(BuildContext context, String key) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t(key))));
  }

  Future<void> _setDefaultReminder(BuildContext context, int? minutes) async {
    final settings = context.read<SettingsProvider>();

    if (minutes != null) {
      final notifications = NotificationService.instance;
      if (!notifications.isReady) {
        _showMessage(context, 'reminder_unavailable');
        return;
      }
      final granted = await notifications.requestPermission();
      if (!granted) {
        if (context.mounted) _showMessage(context, 'reminder_denied');
        return;
      }
    }
    await settings.setDefaultReminder(minutes);
  }

  Future<void> _clearHistory(BuildContext context) async {
    final triage = context.read<TriageProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmSheet(
      context,
      title: t('history_clear_title'),
      message: t('history_clear_message'),
      confirmLabel: t('clear_all'),
      destructive: true,
      icon: Icons.delete_sweep_outlined,
    );
    if (!confirmed) return;

    await triage.clearHistory();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t('history_cleared'))));
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final settings = context.watch<SettingsProvider>();

    return GlassScaffold(
      title: t('settings_title'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          _Section(
            title: t('settings_language'),
            hint: t('settings_language_hint'),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                GlassChip(
                  label: t('lang_name_bn'),
                  selected: language.isBangla,
                  onTap: () => language.setLanguage(AppLanguage.bn),
                ),
                GlassChip(
                  label: t('lang_name_en'),
                  selected: !language.isBangla,
                  onTap: () => language.setLanguage(AppLanguage.en),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Section(
            title: t('settings_reminder'),
            hint: t('settings_reminder_hint'),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final minutes in _reminderOptions)
                  GlassChip(
                    label: reminderLabel(minutes),
                    selected: settings.defaultReminderMinutes == minutes,
                    onTap: () => _setDefaultReminder(context, minutes),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _MenuSection(
            title: t('settings_legal'),
            children: [
              GlassMenuRow(
                icon: Icons.privacy_tip_outlined,
                label: t('privacy_policy'),
                onTap: () => showInfoSheet(
                  context,
                  title: t('privacy_policy'),
                  icon: Icons.privacy_tip_outlined,
                  paragraphs: [
                    t('privacy_p1'),
                    t('privacy_p2'),
                    t('privacy_p3'),
                    t('privacy_p4'),
                    t('privacy_p5'),
                  ],
                ),
              ),
              GlassMenuRow(
                icon: Icons.health_and_safety_outlined,
                label: t('disclaimer_title'),
                showDivider: false,
                onTap: () => showInfoSheet(
                  context,
                  title: t('disclaimer_title'),
                  icon: Icons.health_and_safety_outlined,
                  paragraphs: [t('disclaimer_text'), t('disclaimer_p2')],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MenuSection(
            title: t('settings_data'),
            children: [
              GlassMenuRow(
                icon: Icons.delete_sweep_outlined,
                label: t('clear_history_row'),
                color: AppColors.onGlassError,
                showDivider: false,
                onTap: () => _clearHistory(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MenuSection(
            title: t('about_app'),
            children: [
              GlassMenuRow(
                icon: Icons.info_outline_rounded,
                label: t('about_app'),
                value: AppConstants.appVersion,
                showDivider: false,
                onTap: () => showInfoSheet(
                  context,
                  title: t('about_app'),
                  icon: Icons.favorite_rounded,
                  paragraphs: [t('about_text'), t('about_made')],
                  footer: '${t('version')} ${AppConstants.appVersion}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.hint,
    required this.child,
  });

  final String title;
  final String hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: false,
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.onGlass,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(color: AppColors.onGlassMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.onGlassMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GlassCard(
          blur: false,
          radius: 20,
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}
