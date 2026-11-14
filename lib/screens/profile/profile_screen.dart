import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/triage_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_confirm_sheet.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/glass_menu_row.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/profile_avatar.dart';

/// Profile tab: photo, name, stats, shortcuts and Sign out.
/// [onSwitchTab] switches the bottom navigation (1 = Appointments,
/// 3 = Favorites).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onSwitchTab});

  final ValueChanged<int> onSwitchTab;

  Future<void> _signOut(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    final confirmed = await showConfirmSheet(
      context,
      title: t('sign_out_title'),
      message: t('sign_out_message'),
      confirmLabel: t('sign_out'),
      destructive: true,
      icon: Icons.logout_rounded,
    );
    if (!confirmed) return;

    await auth.signOut();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final appointments = context.watch<AppointmentProvider>();
    final doctors = context.watch<DoctorProvider>();
    final triage = context.watch<TriageProvider>();

    final profile = profileProvider.profile;
    final name = profile.name.isNotEmpty ? profile.name : auth.userName;

    return GlassScaffold(
      title: t('nav_profile'),
      showBack: false,
      actions: [
        GlassIconButton(
          icon: Icons.settings_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          GlassCard(
            radius: 26,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ProfileAvatar(
                  name: name,
                  photoPath: profileProvider.photoPath,
                  size: 92,
                ),
                const SizedBox(height: 12),
                Text(
                  name.isEmpty ? '-' : name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.onGlass,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (auth.userEmail.isNotEmpty)
                  Text(
                    auth.userEmail,
                    style: const TextStyle(color: AppColors.onGlassMuted),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (profile.age != null)
                      _InfoPill(
                        icon: Icons.cake_outlined,
                        text: '${profile.age} ${t('years_old')}',
                      ),
                    if (profile.gender.isNotEmpty)
                      _InfoPill(
                        icon: Icons.person_outline_rounded,
                        text: t('gender_${profile.gender}'),
                      ),
                    if (profile.bloodGroup.isNotEmpty)
                      _InfoPill(
                        icon: Icons.water_drop_outlined,
                        text: profile.bloodGroup,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            blur: false,
            radius: 20,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                _Stat(
                  value: '${appointments.upcoming.length}',
                  label: t('profile_stat_appointments'),
                ),
                const _VerticalDivider(),
                _Stat(
                  value: '${doctors.favoriteDoctors.length}',
                  label: t('profile_stat_favorites'),
                ),
                const _VerticalDivider(),
                _Stat(
                  value: '${triage.history.length}',
                  label: t('profile_stat_checks'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            blur: false,
            radius: 20,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                GlassMenuRow(
                  icon: Icons.calendar_month_outlined,
                  label: t('menu_my_appointments'),
                  onTap: () => onSwitchTab(1),
                ),
                GlassMenuRow(
                  icon: Icons.favorite_border_rounded,
                  label: t('menu_favorites'),
                  onTap: () => onSwitchTab(3),
                ),
                GlassMenuRow(
                  icon: Icons.history_rounded,
                  label: t('menu_history'),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.history),
                ),
                GlassMenuRow(
                  icon: Icons.edit_outlined,
                  label: t('profile_edit'),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.editProfile),
                ),
                GlassMenuRow(
                  icon: Icons.settings_outlined,
                  label: t('menu_settings'),
                  showDivider: false,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.settings),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            blur: false,
            radius: 20,
            padding: EdgeInsets.zero,
            child: GlassMenuRow(
              icon: Icons.logout_rounded,
              label: t('sign_out'),
              color: AppColors.onGlassError,
              showDivider: false,
              onTap: () => _signOut(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onGlass),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.onGlass,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.onGlass,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onGlassMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.glassBorder);
  }
}
