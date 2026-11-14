import 'dart:io';

import 'package:flutter/material.dart';

import '../app/color.dart';

/// Round profile picture, or the first letter of the name when there is no
/// photo.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.photoPath,
    this.size = 84,
  });

  final String name;
  final String? photoPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = photoPath;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassBorder, width: 1.5),
      ),
      child: ClipOval(
        child: path == null
            ? _initial()
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _initial(),
              ),
      ),
    );
  }

  Widget _initial() {
    final trimmed = name.trim();
    return Container(
      color: Colors.white.withValues(alpha: 0.18),
      alignment: Alignment.center,
      child: trimmed.isEmpty
          ? Icon(
              Icons.person_rounded,
              size: size * 0.5,
              color: AppColors.onGlass,
            )
          : Text(
              String.fromCharCode(trimmed.runes.first).toUpperCase(),
              style: TextStyle(
                color: AppColors.onGlass,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
