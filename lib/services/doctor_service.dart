import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../app/assets.dart';
import '../models/doctor_model.dart';
import '../models/specialty_model.dart';

/// Loads specialties and doctors.
/// Reads the JSON files in assets/data/. Firestore replaces this in the
/// Firebase step, so only this file will change.
class DoctorService {
  Future<List<SpecialtyModel>> loadSpecialties() async {
    final raw = await rootBundle.loadString(AppAssets.specialtiesJson);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SpecialtyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DoctorModel>> loadDoctors() async {
    final doctors = await _read(AppAssets.doctorsJson);
    final known = doctors.map((d) => d.id).toSet();

    // More doctors live in a second file so they are easy to add.
    try {
      for (final doctor in await _read(AppAssets.doctorsMoreJson)) {
        if (known.add(doctor.id)) doctors.add(doctor);
      }
    } catch (_) {
      // The extra file is optional.
    }
    return doctors;
  }

  Future<List<DoctorModel>> _read(String path) async {
    final raw = await rootBundle.loadString(path);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
