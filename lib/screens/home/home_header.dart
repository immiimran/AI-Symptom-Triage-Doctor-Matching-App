import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../providers/auth_provider.dart';
import '../../texts/app_texts.dart';
import '../../utils/greeting.dart';

// ignore: unintended_html_in_doc_comment
/// "Hello <name>" + time-based greeting + notification bell.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.onBellTap});

  final VoidCallback? onBellTap;

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthProvider>().firstName;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${t('hello')} $name'.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                t(greetingKey()),
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppColors.surface,
          elevation: 1,
          shadowColor: AppColors.shadow,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onBellTap,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textDark,
                  ),
                  Positioned(
                    top: 12,
                    right: 14,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
