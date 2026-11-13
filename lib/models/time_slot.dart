/// One bookable time in a doctor's chamber. Each slot is also a serial number.
class TimeSlot {
  const TimeSlot({
    required this.start,
    required this.serial,
    required this.isTaken,
    required this.isPast,
  });

  final DateTime start;

  /// 1 for the first slot of the day, 2 for the next, and so on.
  final int serial;
  final bool isTaken;
  final bool isPast;

  bool get isAvailable => !isTaken && !isPast;

  /// 'morning', 'afternoon' or 'evening'.
  String get period {
    if (start.hour < 12) return 'morning';
    if (start.hour < 17) return 'afternoon';
    return 'evening';
  }
}
