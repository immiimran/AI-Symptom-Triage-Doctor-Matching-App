import 'package:flutter/foundation.dart';

import '../app/constants.dart';
import '../models/doctor_model.dart';
import '../models/specialty_model.dart';
import '../services/doctor_service.dart';
import '../services/storage_service.dart';

/// Holds specialties, doctors and the user's favorite doctors.
class DoctorProvider extends ChangeNotifier {
  DoctorProvider({DoctorService? service, StorageService? storage})
    : _service = service ?? DoctorService(),
      _storage = storage ?? StorageService();

  final DoctorService _service;
  final StorageService _storage;

  List<SpecialtyModel> _specialties = [];
  List<DoctorModel> _doctors = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = true;
  bool _hasError = false;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  List<SpecialtyModel> get specialties => List.unmodifiable(_specialties);
  List<DoctorModel> get doctors => List.unmodifiable(_doctors);

  /// Top doctors by rating x review count.
  List<DoctorModel> get popularDoctors {
    final sorted = [..._doctors]
      ..sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
    return sorted.take(AppConstants.popularDoctorCount).toList();
  }

  List<DoctorModel> get favoriteDoctors =>
      _doctors.where((d) => _favoriteIds.contains(d.id)).toList();

  /// Loads data once at startup.
  Future<void> load() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _specialties = await _service.loadSpecialties();
      _doctors = await _service.loadDoctors();
      _favoriteIds = (await _storage.getFavoriteIds()).toSet();
    } catch (_) {
      _hasError = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  DoctorModel? doctorById(String id) {
    for (final doctor in _doctors) {
      if (doctor.id == id) return doctor;
    }
    return null;
  }

  List<DoctorModel> doctorsFor(String specialtyId) =>
      _doctors.where((d) => d.specialtyId == specialtyId).toList();

  /// Name of a specialty in the current language, or empty if unknown.
  String specialtyName(String specialtyId) {
    for (final specialty in _specialties) {
      if (specialty.id == specialtyId) return specialty.name;
    }
    return '';
  }

  bool isFavorite(String doctorId) => _favoriteIds.contains(doctorId);

  Future<void> toggleFavorite(String doctorId) async {
    if (!_favoriteIds.remove(doctorId)) {
      _favoriteIds.add(doctorId);
    }
    notifyListeners();
    await _storage.setFavoriteIds(_favoriteIds.toList());
  }
}
