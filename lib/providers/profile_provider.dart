import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/photo_service.dart';
import '../services/storage_service.dart';

/// Holds the user's profile (name, phone, age, gender, blood group, photo).
class ProfileProvider extends ChangeNotifier {
  ProfileProvider({StorageService? storage, PhotoService? photos})
    : _storage = storage ?? StorageService(),
      _photos = photos ?? PhotoService();

  final StorageService _storage;
  final PhotoService _photos;

  UserProfile _profile = const UserProfile();
  String? _photoPath;

  UserProfile get profile => _profile;

  /// Full path of the profile photo, or null.
  String? get photoPath => _photoPath;

  Future<void> load() async {
    final raw = await _storage.getProfileJson();
    if (raw != null) {
      try {
        _profile = UserProfile.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        _profile = const UserProfile();
      }
    }
    _photoPath = await _photos.resolve(_profile.photoFile);
    notifyListeners();
  }

  Future<void> save(UserProfile profile) async {
    _profile = profile;
    _photoPath = await _photos.resolve(profile.photoFile);
    notifyListeners();
    await _storage.saveProfileJson(jsonEncode(profile.toJson()));
  }
}
