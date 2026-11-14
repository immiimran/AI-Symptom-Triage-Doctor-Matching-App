import 'package:intl/intl.dart';

import '../app/constants.dart';
import '../models/doctor_model.dart';
import '../models/time_slot.dart';
import '../utils/doctor_schedule.dart';

/// Builds the time slots (serial numbers) of a doctor for one date.
/// "04:00 PM - 08:00 PM" with 20-minute slots gives 12 serials.
class SlotService {
  static final DateFormat _timeParser = DateFormat('hh:mm a');

  List<TimeSlot> slotsFor({
    required DoctorModel doctor,
    required DateTime date,
    required bool Function(DateTime slotStart) isBookedByUser,
  }) {
    final range = _parseRange(doctor.chamberTime, date);
    if (range == null) return [];

    final earliest = DateTime.now().add(
      const Duration(minutes: AppConstants.bookingLeadMinutes),
    );
    const step = Duration(minutes: AppConstants.slotMinutes);

    final slots = <TimeSlot>[];
    var cursor = range.start;
    var serial = 1;
    while (!cursor.add(step).isAfter(range.end)) {
      final taken =
          isBookedByUser(cursor) ||
          (AppConstants.demoMode && _simulatedTaken(doctor.id, cursor, serial));
      slots.add(
        TimeSlot(
          start: cursor,
          serial: serial,
          isTaken: taken,
          isPast: cursor.isBefore(earliest),
        ),
      );
      cursor = cursor.add(step);
      serial++;
    }
    return slots;
  }

  /// First date (within the booking window) when the doctor sits and still
  /// has at least one free time.
  DateTime? firstDateWithSlots({
    required DoctorModel doctor,
    required bool Function(DateTime slotStart) isBookedByUser,
  }) {
    final now = DateTime.now();
    for (var i = 0; i < AppConstants.bookingDaysAhead; i++) {
      final date = DateTime(now.year, now.month, now.day + i);
      if (!DoctorSchedule.sitsOn(doctor, date)) continue;
      final slots = slotsFor(
        doctor: doctor,
        date: date,
        isBookedByUser: isBookedByUser,
      );
      if (slots.any((s) => s.isAvailable)) return date;
    }
    return null;
  }

  ({DateTime start, DateTime end})? _parseRange(String text, DateTime date) {
    try {
      final parts = text.split(RegExp(r'\s*[-–]\s*'));
      if (parts.length != 2) return null;
      final a = _timeParser.parse(parts[0].trim().toUpperCase());
      final b = _timeParser.parse(parts[1].trim().toUpperCase());
      final start = DateTime(date.year, date.month, date.day, a.hour, a.minute);
      final end = DateTime(date.year, date.month, date.day, b.hour, b.minute);
      if (!end.isAfter(start)) return null;
      return (start: start, end: end);
    } catch (_) {
      return null;
    }
  }

  /// Demo mode only: marks about one slot in four as "booked by others",
  /// always the same for the same doctor and day.
  bool _simulatedTaken(String doctorId, DateTime slot, int serial) {
    final seed = doctorId.codeUnits.fold<int>(0, (a, b) => a + b);
    return (seed + slot.day * 17 + slot.month * 13 + serial * 7) % 4 == 0;
  }
}
