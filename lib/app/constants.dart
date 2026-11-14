class AppConstants {
  AppConstants._();

  /// Shown in Settings > About.
  static const String appVersion = '1.0.0';

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

  /// National emergency number (Bangladesh).
  static const String emergencyNumber = '999';

  /// How many past symptom checks are kept in history.
  static const int historyLimit = 50;

  // ---- Booking ----
  /// Minutes per serial / time slot.
  static const int slotMinutes = 20;

  /// How many days ahead a patient can book.
  static const int bookingDaysAhead = 14;

  /// Slots starting sooner than this (minutes from now) cannot be booked.
  static const int bookingLeadMinutes = 30;

  /// "Please arrive by" is this many minutes before the slot.
  static const int arriveEarlyMinutes = 15;

  // ---- Reminders ----
  /// Reminder choices, in minutes before the appointment.
  static const List<int> reminderOptions = [1440, 180, 60];

  /// Special value: remind in 1 minute (demo mode testing only).
  static const int testReminderMinutes = -1;

  static const String reminderChannelId = 'appointment_reminders';
  static const String reminderChannelName = 'Appointment reminders';
}
