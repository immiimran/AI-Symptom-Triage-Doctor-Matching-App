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
    final raw = await rootBundle.loadString(AppAssets.doctorsJson);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
