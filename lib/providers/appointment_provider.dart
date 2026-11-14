import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../app/constants.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import '../services/doctor_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../texts/app_texts.dart';
import '../utils/date_utils.dart';

/// Result of turning a reminder on or off.
enum ReminderResult { set, off, denied, tooLate, unsupported }

/// Holds the user's appointments (saved locally for now).
class AppointmentProvider extends ChangeNotifier {
  AppointmentProvider({StorageService? storage, DoctorService? doctorService})
    : _storage = storage ?? StorageService(),
      _doctorService = doctorService ?? DoctorService();

  final StorageService _storage;
  final DoctorService _doctorService;

  List<AppointmentModel> _items = [];

  List<AppointmentModel> get all => List.unmodifiable(_items);

  /// An appointment counts as past one hour after its start time.
  DateTime get _cutoff => DateTime.now().subtract(const Duration(hours: 1));

  /// Upcoming appointments, soonest first.
  List<AppointmentModel> get upcoming {
    final cutoff = _cutoff;
    return _items
        .where(
          (a) =>
              a.status == AppointmentStatus.upcoming &&
              a.dateTime.isAfter(cutoff),
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Completed appointments and those whose time has passed, newest first.
  List<AppointmentModel> get past {
    final cutoff = _cutoff;
    return _items
        .where(
          (a) =>
              a.status == AppointmentStatus.completed ||
              (a.status == AppointmentStatus.upcoming &&
                  !a.dateTime.isAfter(cutoff)),
        )
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// Cancelled appointments, newest first.
  List<AppointmentModel> get cancelled {
    return _items.where((a) => a.status == AppointmentStatus.cancelled).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  AppointmentModel? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// True if an upcoming appointment with this doctor starts at [slotStart].
  bool isSlotTaken(String doctorId, DateTime slotStart) {
    return _items.any(
      (a) =>
          a.doctorId == doctorId &&
          a.status == AppointmentStatus.upcoming &&
          a.dateTime == slotStart,
    );
  }

  Future<void> load() async {
    final raw = await _storage.getAppointmentsJson();

    if (raw == null) {
      // First launch. In demo mode add samples so the screens are not empty.
      _items = AppConstants.demoMode ? await _buildDemoAppointments() : [];
      await _save();
    } else {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _items = list
            .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _items = [];
      }
    }
    notifyListeners();
  }

  /// Creates and saves a new appointment. If the user chose a default
  /// reminder in Settings, it is set right away.
  Future<AppointmentModel> book({
    required DoctorModel doctor,
    required DateTime dateTime,
    required int serialNumber,
    required String patientName,
    required int patientAge,
    String patientGender = '',
    String note = '',
  }) async {
    final appointment = AppointmentModel(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      doctorId: doctor.id,
      patientName: patientName.trim(),
      patientAge: patientAge,
      patientGender: patientGender,
      dateTime: dateTime,
      serialNumber: serialNumber,
      fee: doctor.fee,
      note: note.trim(),
    );
    _items = [..._items, appointment];
    notifyListeners();
    await _save();

    final defaultMinutes = await _storage.getDefaultReminderMinutes();
    if (defaultMinutes != null) {
      await setReminder(
        appointment: appointment,
        doctor: doctor,
        minutesBefore: defaultMinutes,
      );
    }
    return byId(appointment.id) ?? appointment;
  }

  /// Cancels an appointment and its reminder.
  Future<void> cancel(String id) async {
    final appointment = byId(id);
    if (appointment == null) return;
    await NotificationService.instance.cancel(appointment.notificationId);
    _replace(
      appointment.copyWith(
        status: AppointmentStatus.cancelled,
        clearReminder: true,
      ),
    );
    await _save();
  }

  /// Moves an appointment to a new time and serial. If it had a reminder,
  /// the reminder is set again for the new time.
  /// Returns null when there was no reminder, otherwise the reminder result.
  Future<ReminderResult?> reschedule({
    required AppointmentModel appointment,
    required DoctorModel doctor,
    required DateTime newDateTime,
    required int newSerial,
  }) async {
    final oldMinutes = appointment.reminderMinutes;
    await NotificationService.instance.cancel(appointment.notificationId);

    final moved = appointment.copyWith(
      dateTime: newDateTime,
      serialNumber: newSerial,
      clearReminder: true,
    );
    _replace(moved);
    await _save();

    if (oldMinutes == null || oldMinutes == AppConstants.testReminderMinutes) {
      return null;
    }
    return setReminder(
      appointment: moved,
      doctor: doctor,
      minutesBefore: oldMinutes,
    );
  }

  /// Turns the reminder on ([minutesBefore]) or off (null).
  Future<ReminderResult> setReminder({
    required AppointmentModel appointment,
    required DoctorModel doctor,
    required int? minutesBefore,
  }) async {
    final notifications = NotificationService.instance;
    await notifications.cancel(appointment.notificationId);

    if (minutesBefore == null) {
      _replace(appointment.copyWith(clearReminder: true));
      await _save();
      return ReminderResult.off;
    }

    if (!notifications.isReady) return ReminderResult.unsupported;

    final isTest = minutesBefore == AppConstants.testReminderMinutes;
    final when = isTest
        ? DateTime.now().add(const Duration(minutes: 1))
        : appointment.dateTime.subtract(Duration(minutes: minutesBefore));
    if (!when.isAfter(DateTime.now())) return ReminderResult.tooLate;

    final granted = await notifications.requestPermission();
    if (!granted) return ReminderResult.denied;

    final scheduled = await notifications.schedule(
      id: appointment.notificationId,
      title: t('reminder_notification_title'),
      body:
          '${doctor.name} · ${doctor.hospital}\n'
          '${t('serial')} #${appointment.serialNumber} · '
          '${AppDateUtils.time(appointment.dateTime)}',
      when: when,
    );
    if (!scheduled) return ReminderResult.unsupported;

    _replace(appointment.copyWith(reminderMinutes: minutesBefore));
    await _save();
    return ReminderResult.set;
  }

  void _replace(AppointmentModel updated) {
    _items = [
      for (final a in _items)
        if (a.id == updated.id) updated else a,
    ];
    notifyListeners();
  }

  Future<void> _save() async {
    final json = jsonEncode(_items.map((a) => a.toJson()).toList());
    await _storage.saveAppointmentsJson(json);
  }

  Future<List<AppointmentModel>> _buildDemoAppointments() async {
    try {
      final doctors = await _doctorService.loadDoctors();
      if (doctors.isEmpty) return [];
      final first = doctors.first;
      final second = doctors.length > 1 ? doctors[1] : first;
      final now = DateTime.now();
      return [
        AppointmentModel(
          id: 'demo_001',
          doctorId: first.id,
          patientName: 'Demo Patient',
          dateTime: DateTime(now.year, now.month, now.day + 1, 17, 0),
          serialNumber: 4,
          fee: first.fee,
        ),
        AppointmentModel(
          id: 'demo_002',
          doctorId: second.id,
          patientName: 'Demo Patient',
          dateTime: DateTime(now.year, now.month, now.day - 3, 17, 0),
          serialNumber: 3,
          status: AppointmentStatus.completed,
          fee: second.fee,
        ),
      ];
    } catch (_) {
      return [];
    }
  }
}
