import 'package:flutter/material.dart';

import '../app/color.dart';
import '../models/doctor_model.dart';

/// Doctor photo, or an initials avatar when there is no photo.
class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({
    super.key,
    required this.doctor,
    this.size = 64,
    this.radius = 16,
    this.showStatusDot = false,
  });

  final DoctorModel doctor;
  final double size;
  final double radius;

  /// Shows a green dot when the doctor sits today.
  final bool showStatusDot;

  @override
  Widget build(BuildContext context) {
    final avatar = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: doctor.photo.isEmpty
            ? _initials()
            : Image.asset(
                doctor.photo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _initials(),
              ),
      ),
    );

    if (!showStatusDot) return avatar;

    return Stack(
      children: [
        avatar,
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initials() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        doctor.initials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
