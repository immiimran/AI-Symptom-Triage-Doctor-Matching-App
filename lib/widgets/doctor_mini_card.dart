import 'package:flutter/material.dart';

import '../app/color.dart';
import '../models/doctor_model.dart';
import 'doctor_avatar.dart';
import 'glass_card.dart';

/// Compact doctor row for glass screens: photo, name, specialty, hospital.
class DoctorMiniCard extends StatelessWidget {
  const DoctorMiniCard({
    super.key,
    required this.doctor,
    required this.specialtyName,
  });

  final DoctorModel doctor;
  final String specialtyName;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: false,
      radius: 20,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          DoctorAvatar(doctor: doctor, size: 56, radius: 16, onDark: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onGlass,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  specialtyName,
                  style: const TextStyle(
                    color: AppColors.onGlassMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  doctor.hospital,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onGlassMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
