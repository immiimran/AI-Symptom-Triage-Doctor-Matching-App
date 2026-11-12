import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/doctors/doctor_details_screen.dart';
import '../screens/doctors/doctor_list_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/symptom/analyzing_screen.dart';
import '../screens/symptom/symptom_screen.dart';
import '../screens/triage_result/triage_result_screen.dart';
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
  static const String triageResult = '/triage-result';
  static const String doctors = '/doctors';
  static const String doctorDetails = '/doctor-details';
  static const String booking = '/booking';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const MainShell(),
    symptom: (_) => const SymptomScreen(),
    analyzing: (_) => const AnalyzingScreen(),
    triageResult: (_) => const TriageResultScreen(),
    doctors: (_) => const DoctorListScreen(),
    doctorDetails: (_) => const DoctorDetailsScreen(),
    // TODO: replace with the real Booking screen in the next step.
    booking: (_) => const PlaceholderScreen(title: 'Booking'),
  };
}
