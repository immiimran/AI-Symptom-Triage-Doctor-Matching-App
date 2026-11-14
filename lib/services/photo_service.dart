import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Picks a profile photo and keeps it in the app's documents folder.
/// Only the file NAME is stored, because the folder path can change
/// when the app is updated.
class PhotoService {
  final ImagePicker _picker = ImagePicker();

  /// Opens the camera or gallery. Returns the saved file name, or null if
  /// the user cancelled. Throws if the picker fails (permission etc.).
  Future<String?> pickAndSave(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final name = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(picked.path).copy('${dir.path}/$name');
    return name;
  }

  /// Full path of a saved photo, or null if the file is gone.
  Future<String?> resolve(String fileName) async {
    if (fileName.isEmpty) return null;
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$fileName';
    return await File(path).exists() ? path : null;
  }

  Future<void> delete(String fileName) async {
    if (fileName.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A leftover file is harmless.
    }
  }
}
