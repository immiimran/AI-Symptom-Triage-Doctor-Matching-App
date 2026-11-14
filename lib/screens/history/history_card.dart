import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../models/triage_result.dart';
import '../../texts/app_texts.dart';
import '../../utils/date_utils.dart';
import '../../utils/specialty_icons.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/urgency_badge.dart';

/// One past symptom check: date, urgency, text, best match and symptoms.
class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.result,
    required this.specialtyName,
    required this.onTap,
    required this.onDelete,
  });

  static const int _maxChips = 3;

  final TriageResult result;
  final String specialtyName;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final symptoms = result.matchedSymptoms;
    final extra = symptoms.length - _maxChips;

    return GlassCard(
      blur: false,
      radius: 20,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${AppDateUtils.dayLabel(result.createdAt)} · '
                  '${AppDateUtils.time(result.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.onGlassMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              _UrgencyPill(level: result.urgency),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.onGlassMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${result.input.text}"',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.onGlass,
              fontStyle: FontStyle.italic,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  SpecialtyIcons.of(result.topMatch.specialtyId),
                  size: 18,
                  color: AppColors.onGlass,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  specialtyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onGlass,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${result.topMatch.percent}%',
                style: const TextStyle(
                  color: AppColors.onGlass,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (symptoms.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final symptom in symptoms.take(_maxChips))
                  _SymptomChip(text: symptom.name),
                if (extra > 0)
                  _SymptomChip(text: '+$extra ${t('more_symptoms')}'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _UrgencyPill extends StatelessWidget {
  const _UrgencyPill({required this.level});

  final UrgencyLevel level;

  @override
  Widget build(BuildContext context) {
    final color = UrgencyStyle.color(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.85)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(UrgencyStyle.icon(level), size: 13, color: AppColors.onGlass),
          const SizedBox(width: 4),
          Text(
            UrgencyStyle.label(level),
            style: const TextStyle(
              color: AppColors.onGlass,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomChip extends StatelessWidget {
  const _SymptomChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.onGlass, fontSize: 11),
      ),
    );
  }
}
