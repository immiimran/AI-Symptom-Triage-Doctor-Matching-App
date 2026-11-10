class AppConstants {
  AppConstants._();

  /// true = app runs with local demo data, no Firebase needed.
  static const bool demoMode = true;

  /// Minimum time the splash screen stays visible.
  static const Duration splashDuration = Duration(milliseconds: 2500);

  /// Logo entrance animation length.
  static const Duration splashAnimation = Duration(milliseconds: 900);
    /// App display name used by MaterialApp.
  static const String appName = 'Curely';
  
    /// Number of doctors shown in "Popular Doctors" on Home.
  static const int popularDoctorCount = 5;

  /// Currency symbol shown before fees.
  static const String currencySymbol = '৳';
}