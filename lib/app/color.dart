import 'package:flutter/material.dart';

/// Every color used in the app. Change colors here only.
/// Palette is taken from the maroon / white / grey T-shirt reference.
class AppColors {
  AppColors._();

  // ---- Brand ----
  static const Color primary = Color(0xFF7A1E3C);
  static const Color primaryDark = Color(0xFF4F1424);
  static const Color primaryLight = Color(0xFFA04560);
  static const Color accent = Color(0xFFC93C3C); // logo red

  // ---- Neutrals ----
  static const Color background = Color(0xFFF6F1F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color greyLight = Color(0xFFD8D0D1);
  static const Color greyMid = Color(0xFFBDB4B3);
  static const Color textDark = Color(0xFF30161D);
  static const Color textMuted = Color(0xFF6E5B60);

  // ---- Status ----
  static const Color error = Color(0xFFD64545);
  static const Color success = Color(0xFF2E9E6B);
  static const Color warning = Color(0xFFE0A100);

  // ---- Glass / auth screens ----
  static const Color authBgTop = Color(0xFF1E0A12);
  static const Color authBgMid = Color(0xFF3A1224);
  static const Color authBgBottom = Color(0xFF6B1F3A);

  static const Color sphereRose = Color(0xFFE79AB0);
  static const Color sphereRoseDeep = Color(0xFF9C2F52);
  static const Color sphereSilver = Color(0xFFEFE8EA);
  static const Color sphereSilverDeep = Color(0xFF8E7F86);

  static const Color glassFill = Color(0x1FFFFFFF); // white 12%
  static const Color glassBorder = Color(0x4DFFFFFF); // white 30%
  static const Color glassGradientStart = Color(0x2EFFFFFF);
  static const Color glassGradientEnd = Color(0x0FFFFFFF);
  static const Color glassButtonStart = Color(0xFFC9607F);
  static const Color glassButtonEnd = Color(0xFF8F2A4B);

  static const Color onGlass = Color(0xFFFFFFFF);
  static const Color onGlassMuted = Color(0xB3FFFFFF); // white 70%
  static const Color onGlassError = Color(0xFFFFB4B4);

  static const Color star = Color(0xFFF5B301);
  static const Color shadow = Color(0x14000000);
}
