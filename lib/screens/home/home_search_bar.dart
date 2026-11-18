import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../texts/app_texts.dart';

/// Glass search box (opens the doctor list) with a filter button.
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
    final radius = BorderRadius.circular(18);

    return Row(
      children: [
        Expanded(
          child: Material(
            color: AppColors.glassFill,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: const BorderSide(color: AppColors.glassBorder),
            ),
            child: InkWell(
              borderRadius: radius,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.onGlassMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t('search_hint'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.onGlassMuted,
                          fontSize: 14,
                        ),
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
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: onFilterTap,
            child: Ink(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.glassButtonStart,
                    AppColors.glassButtonEnd,
                  ],
                ),
              ),
              child: const Icon(Icons.tune_rounded, color: AppColors.onGlass),
            ),
          ),
        ),
      ],
    );
  }
}
