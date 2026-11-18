import 'package:flutter/material.dart';

import '../app/color.dart';

/// Selectable language row (glass design). Used in onboarding.
class LanguageOptionTile extends StatelessWidget {
  const LanguageOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: radius,
          color: selected
              ? AppColors.onGlass.withValues(alpha: 0.2)
              : AppColors.glassFill,
          border: Border.all(
            color: selected ? AppColors.onGlass : AppColors.glassBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.onGlass,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? AppColors.onGlass : AppColors.onGlassMuted,
            ),
          ],
        ),
      ),
    );
  }
}
