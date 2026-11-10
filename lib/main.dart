import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/constants.dart';
import 'providers/language_provider.dart';

/// App entry point. Keep this file small: only startup initialisation.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // [Splash] Firebase is skipped in demo mode so the app runs without setup.
  if (!AppConstants.demoMode) {
    await Firebase.initializeApp();
  }

  // [Onboarding] Load the saved language before the first frame.
  final languageProvider = LanguageProvider();
  await languageProvider.load();

  // ---- ADD NEW STARTUP INITIALISATION ABOVE THIS LINE ----

  runApp(CurelyApp(languageProvider: languageProvider));
}
