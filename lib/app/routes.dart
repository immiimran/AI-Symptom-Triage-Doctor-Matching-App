import 'package:flutter/material.dart';

import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../widgets/placeholder_screen.dart';

/// All route names and the route table live here.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    // Temporary screens for routes whose implementations are not available yet.
    login: (_) => const PlaceholderScreen(title: 'Login'),
    home: (_) => const PlaceholderScreen(title: 'Home'),
  };
}
