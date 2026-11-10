import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../app/assets.dart';
import '../models/common_symptom.dart';

/// Loads symptom-related data from assets.
class SymptomService {
  Future<List<CommonSymptom>> loadCommonSymptoms() async {
    final raw = await rootBundle.loadString(AppAssets.commonSymptomsJson);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CommonSymptom.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
