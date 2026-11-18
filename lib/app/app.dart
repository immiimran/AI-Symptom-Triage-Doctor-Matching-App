import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/doctor_provider.dart';
import '../providers/language_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/review_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/triage_provider.dart';
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
        ChangeNotifierProvider(create: (_) => TriageProvider()..load()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()..load()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..load()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        // Notifications watch the appointments, so this must stay below
        // the AppointmentProvider.
        ChangeNotifierProxyProvider<AppointmentProvider, NotificationProvider>(
          create: (_) => NotificationProvider()..load(),
          update: (_, appointments, notifications) {
            notifications!.syncAppointments(appointments.all);
            return notifications;
          },
        ),
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
