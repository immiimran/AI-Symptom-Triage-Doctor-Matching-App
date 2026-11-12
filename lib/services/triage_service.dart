import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../app/assets.dart';
import '../app/triage_config.dart';
import '../models/symptom_input.dart';
import '../models/triage_data.dart';
import '../models/triage_result.dart';
import '../utils/text_normalizer.dart';

/// Rule-based triage engine.
/// 1. Find symptoms in the text (keywords) and from selected chips.
/// 2. Add up specialty scores and turn the top ones into percentages.
/// 3. Check red flags first, then decide urgency from severity and more.
/// To use a TFLite or API model later, only this file needs to change.
class TriageService {
  List<SymptomEntry>? _symptoms;
  List<RedFlag>? _redFlags;

  Future<void> _ensureLoaded() async {
    if (_symptoms != null && _redFlags != null) return;

    final symptomsRaw = await rootBundle.loadString(AppAssets.symptomsJson);
    final flagsRaw = await rootBundle.loadString(AppAssets.redFlagsJson);

    _symptoms = (jsonDecode(symptomsRaw) as List<dynamic>)
        .map((e) => SymptomEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    _redFlags = (jsonDecode(flagsRaw) as List<dynamic>)
        .map((e) => RedFlag.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TriageResult> analyze(SymptomInput input) async {
    await _ensureLoaded();

    final text = TextNormalizer.normalize(input.text);
    final matched = _matchSymptoms(text, input.symptomIds);
    final redFlagIds = _findRedFlags(text, input.severity);

    return TriageResult(
      input: input,
      matches: _rankSpecialties(matched, input),
      urgency: _decideUrgency(input, matched, redFlagIds),
      matchedSymptoms: matched
          .map(
            (e) => MatchedSymptom(id: e.id, nameEn: e.nameEn, nameBn: e.nameBn),
          )
          .toList(),
      redFlagIds: redFlagIds,
      noMatch: matched.isEmpty,
      createdAt: DateTime.now(),
    );
  }

  List<SymptomEntry> _matchSymptoms(String text, List<String> selectedIds) {
    return _symptoms!
        .where(
          (entry) =>
              selectedIds.contains(entry.id) ||
              entry.keywords.any((k) => TextNormalizer.containsPhrase(text, k)),
        )
        .toList();
  }

  List<String> _findRedFlags(String text, SymptomSeverity severity) {
    final found = <String>[];
    for (final flag in _redFlags!) {
      final always = flag.always.any(
        (k) => TextNormalizer.containsPhrase(text, k),
      );
      final severeOnly =
          severity == SymptomSeverity.severe &&
          flag.ifSevere.any((k) => TextNormalizer.containsPhrase(text, k));
      if (always || severeOnly) found.add(flag.id);
    }
    return found;
  }

  List<SpecialtyMatch> _rankSpecialties(
    List<SymptomEntry> matched,
    SymptomInput input,
  ) {
    // Nothing recognised: show a safe general suggestion.
    if (matched.isEmpty) {
      final fallback = input.ageGroup == AgeGroup.child
          ? 'pediatrics'
          : 'general';
      return [SpecialtyMatch(specialtyId: fallback, score: 1, percent: 100)];
    }

    final scores = <String, double>{};
    for (final entry in matched) {
      entry.specialties.forEach((id, strength) {
        scores[id] = (scores[id] ?? 0) + strength * entry.weight;
      });
    }
    if (input.ageGroup == AgeGroup.child) {
      scores['pediatrics'] =
          (scores['pediatrics'] ?? 0) + TriageConfig.childPediatricsBoost;
    }
    if (input.ageGroup == AgeGroup.senior) {
      scores['general'] =
          (scores['general'] ?? 0) + TriageConfig.seniorGeneralBoost;
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(TriageConfig.topMatchCount).toList();

    final total = top.fold<double>(0, (sum, e) => sum + e.value);
    final percents = top.map((e) => (e.value / total * 100).round()).toList();
    // Make the percentages add up to exactly 100.
    percents[0] += 100 - percents.fold<int>(0, (a, b) => a + b);

    return [
      for (var i = 0; i < top.length; i++)
        SpecialtyMatch(
          specialtyId: top[i].key,
          score: top[i].value,
          percent: percents[i],
        ),
    ];
  }

  UrgencyLevel _decideUrgency(
    SymptomInput input,
    List<SymptomEntry> matched,
    List<String> redFlagIds,
  ) {
    if (redFlagIds.isNotEmpty) return UrgencyLevel.emergency;

    var points = 0.0;
    if (input.severity == SymptomSeverity.severe) {
      points += TriageConfig.severePoints;
    } else if (input.severity == SymptomSeverity.moderate) {
      points += TriageConfig.moderatePoints;
    }
    if (input.duration == SymptomDuration.overWeek) {
      points += TriageConfig.longDurationPoints;
    }
    final vulnerable =
        input.ageGroup != AgeGroup.adult &&
        input.severity != SymptomSeverity.mild;
    if (vulnerable) points += TriageConfig.vulnerableAgePoints;
    if (matched.any((e) => e.urgentHint)) {
      points += TriageConfig.urgentHintPoints;
    }

    return points >= TriageConfig.urgentThreshold
        ? UrgencyLevel.urgent
        : UrgencyLevel.routine;
  }
}
