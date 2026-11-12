import 'package:flutter/material.dart';

import '../providers/doctor_provider.dart';
import '../texts/app_texts.dart';

/// Toggles a favorite doctor and shows a short message.
Future<void> toggleFavoriteWithMessage(
  BuildContext context,
  DoctorProvider doctors,
  String doctorId,
) async {
  final wasFavorite = doctors.isFavorite(doctorId);
  final messenger = ScaffoldMessenger.of(context);
  await doctors.toggleFavorite(doctorId);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(t(wasFavorite ? 'removed_favorite' : 'added_favorite')),
        duration: const Duration(milliseconds: 1500),
      ),
    );
}
