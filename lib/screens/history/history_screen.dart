import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../models/triage_result.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/triage_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_chip.dart';
import '../../widgets/glass_confirm_sheet.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/urgency_badge.dart';
import 'history_card.dart';

/// List of past AI symptom checks. Filter by urgency, open, or delete.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  UrgencyLevel? _filter;

  Future<void> _delete(TriageResult result) async {
    final provider = context.read<TriageProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmSheet(
      context,
      title: t('history_delete_title'),
      message: t('history_delete_message'),
      confirmLabel: t('delete'),
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;

    await provider.deleteFromHistory(result);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t('history_deleted'))));
  }

  Future<void> _clearAll() async {
    final provider = context.read<TriageProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmSheet(
      context,
      title: t('history_clear_title'),
      message: t('history_clear_message'),
      confirmLabel: t('clear_all'),
      destructive: true,
      icon: Icons.delete_sweep_outlined,
    );
    if (!confirmed) return;

    await provider.clearHistory();
    setState(() => _filter = null);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t('history_cleared'))));
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final triage = context.watch<TriageProvider>();
    final doctors = context.watch<DoctorProvider>();

    final all = triage.history;
    final list = _filter == null
        ? all
        : all.where((r) => r.urgency == _filter).toList();

    return GlassScaffold(
      title: t('history_title'),
      actions: [
        if (all.isNotEmpty)
          GlassIconButton(icon: Icons.delete_sweep_outlined, onTap: _clearAll),
      ],
      body: all.isEmpty
          ? const _EmptyState()
          : Column(
              children: [
                SizedBox(
                  height: 40,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: [
                      GlassChip(
                        label: t('all'),
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      for (final level in UrgencyLevel.values) ...[
                        const SizedBox(width: 8),
                        GlassChip(
                          label: UrgencyStyle.label(level),
                          selected: _filter == level,
                          onTap: () => setState(() => _filter = level),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Text(
                            t('history_empty'),
                            style: const TextStyle(
                              color: AppColors.onGlassMuted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          itemCount: list.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final result = list[index];
                            return HistoryCard(
                              result: result,
                              specialtyName: doctors.specialtyName(
                                result.topMatch.specialtyId,
                              ),
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.triageResult,
                                arguments: result,
                              ),
                              onDelete: () => _delete(result),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.history_rounded,
                size: 44,
                color: AppColors.sphereRose,
              ),
              const SizedBox(height: 12),
              Text(
                t('history_empty'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onGlass,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t('history_empty_hint'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onGlassMuted),
              ),
              const SizedBox(height: 18),
              GlassButton(
                label: t('symptom_card_button'),
                onPressed: () =>
                    Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.symptom),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
