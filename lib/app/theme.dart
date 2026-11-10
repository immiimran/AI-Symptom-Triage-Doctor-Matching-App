import 'package:flutter/material.dart';

/// App-wide colors and theme. Change colors here only.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFFA8245C);
  static const Color primaryDark = Color(0xFF8A1A4C);
  static const Color navy = Color(0xFF14174F);
  static const Color softPink = Color(0xFFFBD3E2);
  static const Color background = Color(0xFFFBF3F7);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
        ),
        scaffoldBackgroundColor: background,
        // বাংলা font যোগ করার পর এখানে fontFamily বসাবেন, যেমন 'HindSiliguri'
      );
}