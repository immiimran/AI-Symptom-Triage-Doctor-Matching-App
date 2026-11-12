import 'package:flutter/material.dart';

import '../app/color.dart';
import '../texts/app_texts.dart';
import '../utils/specialty_icons.dart';

/// One specialty with an animated percentage bar.
class SpecialtyMatchBar extends StatelessWidget {
  const SpecialtyMatchBar({
    super.key,
    required this.specialtyId,
    required this.name,
    required this.percent,
    this.isTop = false,
  });

  final String specialtyId;
  final String name;
  final int percent;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isTop ? AppColors.primary : AppColors.greyLight,
          width: isTop ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  SpecialtyIcons.of(specialtyId),
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (isTop)
                      Text(
                        t('best_match'),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '$percent%',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  color: AppColors.primary,
                  backgroundColor: AppColors.greyLight.withValues(alpha: 0.6),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}