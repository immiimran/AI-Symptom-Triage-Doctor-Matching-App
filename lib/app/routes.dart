import 'package:curely/screens/appoinment/reschedule_screen.dart';
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/booking/booking_success_screen.dart';
import '../screens/doctors/doctor_details_screen.dart';
import '../screens/doctors/doctor_list_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/symptom/analyzing_screen.dart';
import '../screens/symptom/symptom_screen.dart';
import '../screens/triage_result/triage_result_screen.dart';

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
  static const String history = '/history';
  static const String doctors = '/doctors';
  static const String doctorDetails = '/doctor-details';
  static const String booking = '/booking';
  static const String bookingSuccess = '/booking-success';
  static const String reschedule = '/reschedule';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        onboarding: (_) => const OnboardingScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const MainShell(),
        symptom: (_) => const SymptomScreen(),
        analyzing: (_) => const AnalyzingScreen(),
        triageResult: (_) => const TriageResultScreen(),
        history: (_) => const HistoryScreen(),
        doctors: (_) => const DoctorListScreen(),
        doctorDetails: (_) => const DoctorDetailsScreen(),
        booking: (_) => const BookingScreen(),
        bookingSuccess: (_) => const BookingSuccessScreen(),
        reschedule: (_) => const RescheduleScreen(),
        editProfile: (_) => const EditProfileScreen(),
        settings: (_) => const SettingsScreen(),
      };
}