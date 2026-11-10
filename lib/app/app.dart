// নতুন ডাক্তার যোগ: একটা { ... } block কপি করে নতুন id (d007) দিন
// এবং কমা ঠিক রাখুন। ছবি দিতে চাইলে ছবি assets/images/doctors/ folder-এ
// রাখুন, pubspec.yaml-এর assets-এ - assets/images/doctors/ যোগ করুন,
// আর JSON-এ "photo": "assets/images/doctors/dr_rahim.png" লিখুন।
// photo ফাঁকা থাকলে নামের আদ্যক্ষর দেখাবে। ছবি শুধু আপনার নিজের বা license-সহ ছবি দিন।

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/doctor_provider.dart';
import '../providers/language_provider.dart';
import 'constants.dart';
import 'routes.dart';
import 'theme.dart';

/// Root widget: registers providers, theme and routes.
class CurelyApp extends StatelessWidget {
  const CurelyApp({super.key, required this.languageProvider});

  /// Created and loaded in main() so the saved language is ready at launch.
  final LanguageProvider languageProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()..load()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()..load()),
        // ---- ADD NEW PROVIDERS ABOVE THIS LINE ----
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
