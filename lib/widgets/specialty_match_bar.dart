import 'package:flutter/material.dart';

import '../app/color.dart';
import '../texts/app_texts.dart';
import '../utils/specialty_icons.dart';
import 'glass_card.dart';

/// One specialty with an animated percentage bar (glass design).
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
    return GlassCard(
      blur: false,
      radius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTop
                      ? AppColors.sphereRose.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: isTop ? AppColors.sphereRose : AppColors.glassBorder,
                  ),
                ),
                child: Icon(
                  SpecialtyIcons.of(specialtyId),
                  size: 22,
                  color: AppColors.onGlass,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.onGlass,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isTop)
                      Text(
                        t('best_match'),
                        style: const TextStyle(
                          color: AppColors.sphereRose,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: AppColors.onGlass,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  color: isTop ? AppColors.sphereRose : AppColors.onGlass,
                  backgroundColor: AppColors.onGlass.withValues(alpha: 0.15),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
