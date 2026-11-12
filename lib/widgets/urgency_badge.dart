import 'package:flutter/material.dart';

import '../app/color.dart';
import '../models/triage_result.dart';
import '../texts/app_texts.dart';

/// Color and icon for each urgency level.
class UrgencyStyle {
  UrgencyStyle._();

  static Color color(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.emergency:
        return AppColors.error;
      case UrgencyLevel.urgent:
        return AppColors.urgent;
      case UrgencyLevel.routine:
        return AppColors.success;
    }
  }

  static IconData icon(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.emergency:
        return Icons.emergency_rounded;
      case UrgencyLevel.urgent:
        return Icons.access_time_filled_rounded;
      case UrgencyLevel.routine:
        return Icons.check_circle_rounded;
    }
  }

  static String label(UrgencyLevel level) => t('urgency_${level.name}');
}

/// Small colored pill: icon + urgency name.
class UrgencyBadge extends StatelessWidget {
  const UrgencyBadge({super.key, required this.level});

  final UrgencyLevel level;

  @override
  Widget build(BuildContext context) {
    final color = UrgencyStyle.color(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(UrgencyStyle.icon(level), size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            UrgencyStyle.label(level),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
