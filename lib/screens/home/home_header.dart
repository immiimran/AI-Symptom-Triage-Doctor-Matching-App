import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/profile_provider.dart';
import '../../texts/app_texts.dart';
import '../../utils/greeting.dart';
import '../../widgets/profile_avatar.dart';

/// Profile photo, "Hello <name>", time-based greeting, language switch and
/// the notification bell with an unread counter.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onBellTap,
    required this.onAvatarTap,
  });

  final VoidCallback onBellTap;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final language = context.watch<LanguageProvider>();
    final profile = context.watch<ProfileProvider>();
    final unread = context.watch<NotificationProvider>().unreadCount;

    final fullName = profile.profile.name.isNotEmpty
        ? profile.profile.name
        : auth.userName;

    return Row(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: ProfileAvatar(
            name: fullName,
            photoPath: profile.photoPath,
            size: 52,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${t('hello')} ${auth.firstName}'.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.onGlass,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                t(greetingKey()),
                style: const TextStyle(
                  color: AppColors.onGlassMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        // Shows the language you will switch TO.
        _LanguageButton(
          label: language.isBangla ? t('lang_name_en') : t('lang_name_bn'),
          onTap: () => language.setLanguage(
            language.isBangla ? AppLanguage.en : AppLanguage.bn,
          ),
        ),
        const SizedBox(width: 10),
        _BellButton(unread: unread, onTap: onBellTap),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glassFill,
      shape: const StadiumBorder(
        side: BorderSide(color: AppColors.glassBorder),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.translate_rounded,
                size: 18,
                color: AppColors.onGlass,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.onGlass,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.unread, required this.onTap});

  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glassFill,
      shape: const CircleBorder(side: BorderSide(color: AppColors.glassBorder)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.onGlass,
                size: 24,
              ),
              if (unread > 0)
                Positioned(
                  top: 3,
                  right: 3,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.onGlass, width: 1.2),
                    ),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        color: AppColors.onGlass,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
