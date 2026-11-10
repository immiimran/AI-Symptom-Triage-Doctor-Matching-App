import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/symptom/symptom_screen.dart';
import '../widgets/placeholder_screen.dart';

/// All route names and the route table live here.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String symptom = '/symptom';
  static const String analyzing = '/analyzing';
  static const String doctors = '/doctors';
  static const String doctorDetails = '/doctor-details';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const MainShell(),
    symptom: (_) => const SymptomScreen(),
    analyzing: (_) => const PlaceholderScreen(title: 'Analyzing'),
    doctors: (_) => const PlaceholderScreen(title: 'Doctors'),
    doctorDetails: (_) => const PlaceholderScreen(title: 'Doctor Details'),
  };
}
