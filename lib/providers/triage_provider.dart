import 'package:flutter/foundation.dart';

import '../models/common_symptom.dart';
import '../services/symptom_service.dart';

/// Holds data for the symptom flow.
/// (Analysis result is added here in the next steps.)
class TriageProvider extends ChangeNotifier {
  TriageProvider({SymptomService? service})
    : _service = service ?? SymptomService();

  final SymptomService _service;

  List<CommonSymptom> _commonSymptoms = [];
  bool _isLoading = true;

  List<CommonSymptom> get commonSymptoms => List.unmodifiable(_commonSymptoms);
  bool get isLoading => _isLoading;

  Future<void> load() async {
    try {
      _commonSymptoms = await _service.loadCommonSymptoms();
    } catch (_) {
      _commonSymptoms = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}
