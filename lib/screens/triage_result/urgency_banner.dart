import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../models/triage_result.dart';
import '../../texts/app_texts.dart';
import '../../widgets/urgency_badge.dart';

/// Colored glass card at the top of the result. For emergencies it also
/// shows a big "Call 999" button.
class UrgencyBanner extends StatelessWidget {
  const UrgencyBanner({super.key, required this.urgency, required this.onCall});

  final UrgencyLevel urgency;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final color = UrgencyStyle.color(urgency);
    final radius = BorderRadius.circular(26);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: color.withValues(alpha: 0.8)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.35),
                color.withValues(alpha: 0.12),
              ],
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color,
                    child: Icon(
                      UrgencyStyle.icon(urgency),
                      color: AppColors.onGlass,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          UrgencyStyle.label(urgency),
                          style: const TextStyle(
                            color: AppColors.onGlass,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t('advice_${urgency.name}'),
                          style: const TextStyle(
                            color: AppColors.onGlass,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (urgency == UrgencyLevel.emergency) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_rounded),
                  label: Text(t('call_emergency')),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onGlass,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
