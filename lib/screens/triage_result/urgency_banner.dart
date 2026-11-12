import 'package:flutter/material.dart';

import '../../models/triage_result.dart';
import '../../texts/app_texts.dart';
import '../../widgets/urgency_badge.dart';

/// Colored card at the top of the result. For emergencies it also shows a
/// big "Call 999" button.
class UrgencyBanner extends StatelessWidget {
  const UrgencyBanner({super.key, required this.urgency, required this.onCall});

  final UrgencyLevel urgency;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final color = UrgencyStyle.color(urgency);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.5)),
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
                  color: Colors.white,
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
                      style: textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t('advice_${urgency.name}'),
                      style: textTheme.bodyMedium,
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
                backgroundColor: color,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
    );
  }
}
