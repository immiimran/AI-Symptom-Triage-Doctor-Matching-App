import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
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
