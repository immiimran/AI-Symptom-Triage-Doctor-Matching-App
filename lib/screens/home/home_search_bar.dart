import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../texts/app_texts.dart';

/// Search box (opens the doctor list) with a filter button.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.onTap,
    required this.onFilterTap,
  });

  final VoidCallback onTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: AppColors.surface,
            elevation: 1,
            shadowColor: AppColors.shadow,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t('search_hint'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onFilterTap,
            child: const SizedBox(
              width: 52,
              height: 52,
              child: Icon(Icons.tune_rounded, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
