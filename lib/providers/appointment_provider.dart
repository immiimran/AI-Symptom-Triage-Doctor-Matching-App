import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../app/constants.dart';
import '../models/appointment_model.dart';
import '../services/doctor_service.dart';
import '../services/storage_service.dart';

/// Holds the user's appointments (saved locally for now).
class AppointmentProvider extends ChangeNotifier {
  AppointmentProvider({StorageService? storage, DoctorService? doctorService})
    : _storage = storage ?? StorageService(),
      _doctorService = doctorService ?? DoctorService();

  final StorageService _storage;
  final DoctorService _doctorService;

  List<AppointmentModel> _items = [];

  List<AppointmentModel> get all => List.unmodifiable(_items);

  /// Upcoming appointments, soonest first.
  List<AppointmentModel> get upcoming {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    return _items
        .where(
          (a) =>
              a.status == AppointmentStatus.upcoming &&
              a.dateTime.isAfter(cutoff),
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<void> load() async {
    final raw = await _storage.getAppointmentsJson();

    if (raw == null) {
      // First launch. In demo mode add one sample so Home is not empty.
      _items = AppConstants.demoMode ? await _buildDemoAppointments() : [];
      await _save();
    } else {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _items = list
            .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _items = [];
      }
    }
    notifyListeners();
  }

  Future<void> add(AppointmentModel appointment) async {
    _items = [..._items, appointment];
    notifyListeners();
    await _save();
  }

  Future<void> cancel(String id) async {
    _items = [
      for (final a in _items)
        if (a.id == id) a.copyWith(status: AppointmentStatus.cancelled) else a,
    ];
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final json = jsonEncode(_items.map((a) => a.toJson()).toList());
    await _storage.saveAppointmentsJson(json);
  }

  Future<List<AppointmentModel>> _buildDemoAppointments() async {
    try {
      final doctors = await _doctorService.loadDoctors();
      if (doctors.isEmpty) return [];
      final now = DateTime.now();
      return [
        AppointmentModel(
          id: 'demo_001',
          doctorId: doctors.first.id,
          patientName: 'Demo Patient',
          dateTime: DateTime(now.year, now.month, now.day + 1, 17, 0),
          serialNumber: 7,
        ),
      ];
    } catch (_) {
      return [];
    }
  }
}
