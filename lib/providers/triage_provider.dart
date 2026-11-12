import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../app/constants.dart';
import '../models/common_symptom.dart';
import '../models/symptom_input.dart';
import '../models/triage_result.dart';
import '../services/storage_service.dart';
import '../services/symptom_service.dart';
import '../services/triage_service.dart';

/// Holds data for the symptom flow: quick-pick chips, the analysis
/// engine and the history of past checks.
class TriageProvider extends ChangeNotifier {
  TriageProvider({
    SymptomService? service,
    TriageService? triage,
    StorageService? storage,
  }) : _service = service ?? SymptomService(),
       _triage = triage ?? TriageService(),
       _storage = storage ?? StorageService();

  final SymptomService _service;
  final TriageService _triage;
  final StorageService _storage;

  List<CommonSymptom> _commonSymptoms = [];
  List<TriageResult> _history = [];
  TriageResult? _lastResult;
  bool _isLoading = true;

  List<CommonSymptom> get commonSymptoms => List.unmodifiable(_commonSymptoms);

  /// Past checks, newest first.
  List<TriageResult> get history => List.unmodifiable(_history);
  TriageResult? get lastResult => _lastResult;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    try {
      _commonSymptoms = await _service.loadCommonSymptoms();
    } catch (_) {
      _commonSymptoms = [];
    }

    final raw = await _storage.getSymptomHistoryJson();
    if (raw != null) {
      try {
        _history = (jsonDecode(raw) as List<dynamic>)
            .map((e) => TriageResult.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _history = [];
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Runs the triage engine and saves the result in history.
  Future<TriageResult> analyze(SymptomInput input) async {
    final result = await _triage.analyze(input);
    _lastResult = result;
    _history = [result, ..._history].take(AppConstants.historyLimit).toList();
    notifyListeners();
    await _saveHistory();
    return result;
  }

  Future<void> _saveHistory() async {
    final json = jsonEncode(_history.map((r) => r.toJson()).toList());
    await _storage.saveSymptomHistoryJson(json);
  }
}
