import 'package:flutter/material.dart';

/// Maps a specialty id to an icon. Replace with images later if you like.
class SpecialtyIcons {
  SpecialtyIcons._();

  static IconData of(String specialtyId) {
    switch (specialtyId) {
      case 'cardiology':
        return Icons.monitor_heart_outlined;
      case 'neurology':
        return Icons.psychology_outlined;
      case 'gastro':
        return Icons.lunch_dining_outlined;
      case 'orthopedics':
        return Icons.accessibility_new_rounded;
      case 'dermatology':
        return Icons.face_retouching_natural;
      case 'gynecology':
        return Icons.pregnant_woman_rounded;
      case 'pediatrics':
        return Icons.child_care_rounded;
      case 'ent':
        return Icons.hearing_rounded;
      case 'eye':
        return Icons.visibility_outlined;
      default:
        return Icons.medical_services_outlined;
    }
  }
}
