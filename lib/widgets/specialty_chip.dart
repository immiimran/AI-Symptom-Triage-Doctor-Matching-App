import 'package:flutter/material.dart';

import '../app/color.dart';
import '../models/specialty_model.dart';
import '../utils/specialty_icons.dart';

/// Round specialty icon with its name below.
class SpecialtyChip extends StatelessWidget {
  const SpecialtyChip({
    super.key,
    required this.specialty,
    required this.onTap,
  });

  final SpecialtyModel specialty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          children: [
            Material(
              color: AppColors.surface,
              elevation: 1,
              shadowColor: AppColors.shadow,
              shape: const CircleBorder(),
              child: SizedBox(
                width: 62,
                height: 62,
                child: Icon(
                  SpecialtyIcons.of(specialty.id),
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              specialty.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
