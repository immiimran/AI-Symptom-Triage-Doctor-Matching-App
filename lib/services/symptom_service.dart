import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../app/assets.dart';
import '../models/common_symptom.dart';

/// Loads symptom-related data from assets.
class SymptomService {
  Future<List<CommonSymptom>> loadCommonSymptoms() async {
    final symptoms = await _read(AppAssets.commonSymptomsJson);
    final known = symptoms.map((s) => s.id).toSet();

    // More quick-pick symptoms live in a second file.
    try {
      for (final symptom in await _read(AppAssets.commonSymptomsMoreJson)) {
        if (known.add(symptom.id)) symptoms.add(symptom);
      }
    } catch (_) {
      // The extra file is optional.
    }
    return symptoms;
  }

  Future<List<CommonSymptom>> _read(String path) async {
    final raw = await rootBundle.loadString(path);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CommonSymptom.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
