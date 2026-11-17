import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../models/appointment_model.dart';
import '../services/storage_service.dart';

/// In-app notification list (the bell on Home).
/// It watches the appointments and adds a notification when one is booked,
/// cancelled, moved, gets a reminder, or is coming up within 24 hours.
/// It also adds a welcome message and one health tip per day.
class NotificationProvider extends ChangeNotifier {
  NotificationProvider({StorageService? storage})
    : _storage = storage ?? StorageService();

  static const int _maxItems = 60;

  /// Number of daily tips in the texts files (tip_daily_0, tip_daily_1, ...).
  static const int dailyTipCount = 8;

  final StorageService _storage;

  List<AppNotification> _items = [];
  Map<String, _Snapshot> _snapshot = {};
  List<AppointmentModel> _latest = const [];
  bool _baselineDone = false;
  bool _ready = false;
  bool _disposed = false;

  /// Newest first.
  List<AppNotification> get items {
    final sorted = [..._items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  int get unreadCount => _items.where((n) => !n.isRead).length;

  Future<void> load() async {
    final raw = await _storage.getNotificationCenterJson();
    if (raw != null) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _baselineDone = (data['baseline'] as bool?) ?? false;
        _items = ((data['items'] as List<dynamic>?) ?? const [])
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
        final snapshot = (data['snapshot'] as Map<String, dynamic>?) ?? {};
        _snapshot = snapshot.map(
          (id, value) =>
              MapEntry(id, _Snapshot.fromJson(value as Map<String, dynamic>)),
        );
      } catch (_) {
        _items = [];
        _snapshot = {};
        _baselineDone = false;
      }
    }
    _ready = true;

    // The appointments may have arrived before the saved data was read.
    if (_process(_latest)) await _save();
    _notify();
  }

  /// Called every time the appointments change.
  void syncAppointments(List<AppointmentModel> appointments) {
    _latest = appointments;
    if (!_ready) return;
    if (_process(appointments)) {
      unawaited(_save());
      // This runs while widgets are building, so notify a moment later.
      scheduleMicrotask(_notify);
    }
  }

  Future<void> markRead(String id) async {
    _items = [
      for (final n in _items) n.id == id ? n.copyWith(isRead: true) : n,
    ];
    _notify();
    await _save();
  }

  Future<void> markAllRead() async {
    _items = [for (final n in _items) n.copyWith(isRead: true)];
    _notify();
    await _save();
  }

  Future<void> remove(String id) async {
    _items = _items.where((n) => n.id != id).toList();
    _notify();
    await _save();
  }

  Future<void> clearAll() async {
    _items = [];
    _notify();
    await _save();
  }

  /// Compares the appointments with the last known state and adds
  /// notifications for what changed. Returns true if anything changed.
  bool _process(List<AppointmentModel> list) {
    final now = DateTime.now();
    var changed = false;

    if (!_baselineDone) {
      // Wait for the appointments to load. They become the starting point,
      // so existing ones do not create notifications.
      if (list.isEmpty) return false;
      _snapshot = {for (final a in list) a.id: _Snapshot.of(a)};
      _baselineDone = true;
      _add(
        AppNotification(
          id: 'welcome',
          type: NotificationType.welcome,
          createdAt: now,
        ),
      );
      changed = true;
    } else {
      for (final a in list) {
        final before = _snapshot[a.id];

        if (before == null) {
          changed =
              _add(
                AppNotification(
                  id: 'booked_${a.id}',
                  type: NotificationType.booked,
                  createdAt: now,
                  appointmentId: a.id,
                  doctorId: a.doctorId,
                  dateTime: a.dateTime,
                  serial: a.serialNumber,
                ),
              ) ||
              changed;
        } else {
          if (before.status != AppointmentStatus.cancelled &&
              a.status == AppointmentStatus.cancelled) {
            changed =
                _add(
                  AppNotification(
                    id: 'cancelled_${a.id}',
                    type: NotificationType.cancelled,
                    createdAt: now,
                    appointmentId: a.id,
                    doctorId: a.doctorId,
                    dateTime: a.dateTime,
                    serial: a.serialNumber,
                  ),
                ) ||
                changed;
          }
          if (a.status == AppointmentStatus.upcoming &&
              before.dateTime != a.dateTime.toIso8601String()) {
            changed =
                _add(
                  AppNotification(
                    id: 'moved_${a.id}_${a.dateTime.millisecondsSinceEpoch}',
                    type: NotificationType.rescheduled,
                    createdAt: now,
                    appointmentId: a.id,
                    doctorId: a.doctorId,
                    dateTime: a.dateTime,
                    serial: a.serialNumber,
                  ),
                ) ||
                changed;
          }
          if (a.reminderMinutes != null &&
              a.reminderMinutes != before.reminder) {
            changed =
                _add(
                  AppNotification(
                    id: 'reminder_${a.id}_${now.microsecondsSinceEpoch}',
                    type: NotificationType.reminderSet,
                    createdAt: now,
                    appointmentId: a.id,
                    doctorId: a.doctorId,
                    dateTime: a.dateTime,
                    serial: a.serialNumber,
                    reminderMinutes: a.reminderMinutes,
                  ),
                ) ||
                changed;
          }
        }

        final now0 = _Snapshot.of(a);
        if (before == null || !before.sameAs(now0)) {
          _snapshot[a.id] = now0;
          changed = true;
        }
      }
    }

    // "Coming up": an upcoming appointment within the next 24 hours.
    for (final a in list) {
      if (a.status != AppointmentStatus.upcoming) continue;
      final until = a.dateTime.difference(now);
      if (until > Duration.zero && until <= const Duration(hours: 24)) {
        changed =
            _add(
              AppNotification(
                id: 'soon_${a.id}_${a.dateTime.millisecondsSinceEpoch}',
                type: NotificationType.soon,
                createdAt: now,
                appointmentId: a.id,
                doctorId: a.doctorId,
                dateTime: a.dateTime,
                serial: a.serialNumber,
              ),
            ) ||
            changed;
      }
    }

    // One health tip per day.
    final today =
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    changed =
        _add(
          AppNotification(
            id: 'tip_$today',
            type: NotificationType.tip,
            createdAt: now,
            tipIndex: dayOfYear % dailyTipCount,
          ),
        ) ||
        changed;

    return changed;
  }

  /// Adds a notification unless one with the same id exists.
  bool _add(AppNotification notification) {
    if (_items.any((n) => n.id == notification.id)) return false;
    _items = [notification, ..._items];
    if (_items.length > _maxItems) {
      final sorted = [..._items]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _items = sorted.take(_maxItems).toList();
    }
    return true;
  }

  Future<void> _save() async {
    final data = {
      'baseline': _baselineDone,
      'items': _items.map((n) => n.toJson()).toList(),
      'snapshot': _snapshot.map((id, s) => MapEntry(id, s.toJson())),
    };
    await _storage.saveNotificationCenterJson(jsonEncode(data));
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// What an appointment looked like the last time we checked.
class _Snapshot {
  const _Snapshot({
    required this.status,
    required this.dateTime,
    this.reminder,
  });

  final AppointmentStatus status;
  final String dateTime;
  final int? reminder;

  factory _Snapshot.of(AppointmentModel a) => _Snapshot(
    status: a.status,
    dateTime: a.dateTime.toIso8601String(),
    reminder: a.reminderMinutes,
  );

  bool sameAs(_Snapshot other) =>
      status == other.status &&
      dateTime == other.dateTime &&
      reminder == other.reminder;

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'date_time': dateTime,
    'reminder': reminder,
  };

  factory _Snapshot.fromJson(Map<String, dynamic> json) {
    return _Snapshot(
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => AppointmentStatus.upcoming,
      ),
      dateTime: (json['date_time'] as String?) ?? '',
      reminder: (json['reminder'] as num?)?.toInt(),
    );
  }
}
