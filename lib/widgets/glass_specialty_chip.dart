import 'package:flutter/material.dart';

import '../app/color.dart';
import '../models/specialty_model.dart';
import '../utils/specialty_icons.dart';

/// Round glass icon with the specialty name below.
class GlassSpecialtyChip extends StatelessWidget {
  const GlassSpecialtyChip({
    super.key,
    required this.specialty,
    required this.onTap,
  });

  final SpecialtyModel specialty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.glassGradientStart,
                    AppColors.glassGradientEnd,
                  ],
                ),
              ),
              child: Icon(
                SpecialtyIcons.of(specialty.id),
                size: 28,
                color: AppColors.onGlass,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              specialty.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.onGlass,
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
