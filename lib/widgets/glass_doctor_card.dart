import 'package:flutter/material.dart';

import '../app/color.dart';
import '../app/constants.dart';
import '../models/doctor_model.dart';
import '../texts/app_texts.dart';
import 'doctor_avatar.dart';
import 'glass_card.dart';

/// Doctor row for glass screens: photo, name, specialty, rating, hospital,
/// fee, availability, optional match percentage and a favorite heart.
class GlassDoctorCard extends StatelessWidget {
  const GlassDoctorCard({
    super.key,
    required this.doctor,
    required this.specialtyName,
    required this.rating,
    required this.reviewCount,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    this.matchPercent,
  });

  final DoctorModel doctor;
  final String specialtyName;
  final double rating;
  final int reviewCount;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  /// Specialty match from the AI result, or null when browsing.
  final int? matchPercent;

  @override
  Widget build(BuildContext context) {
    final muted = const TextStyle(color: AppColors.onGlassMuted, fontSize: 12);
    final showMatch = matchPercent != null && matchPercent! > 0;

    return GlassCard(
      blur: false,
      radius: 22,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DoctorAvatar(
            doctor: doctor,
            size: 84,
            radius: 18,
            showStatusDot: doctor.isAvailableToday,
            onDark: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        doctor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.onGlass,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onFavoriteTap,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 22,
                          color: isFavorite
                              ? AppColors.sphereRose
                              : AppColors.onGlass,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  specialtyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 17,
                            color: AppColors.star,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.onGlass,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '($reviewCount ${t('reviews')})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${AppConstants.currencySymbol}${doctor.fee}',
                      style: const TextStyle(
                        color: AppColors.onGlass,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.local_hospital_outlined,
                      size: 14,
                      color: AppColors.onGlassMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.hospital,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: muted,
                      ),
                    ),
                  ],
                ),
                if (doctor.isAvailableToday || showMatch) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (doctor.isAvailableToday)
                        _Pill(
                          text: t('available_today'),
                          color: AppColors.success,
                        ),
                      if (showMatch)
                        _Pill(
                          text: '$matchPercent% ${t('match_percent')}',
                          color: AppColors.sphereRose,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.onGlass,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
