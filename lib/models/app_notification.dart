enum NotificationType {
  welcome,
  booked,
  cancelled,
  rescheduled,
  reminderSet,
  soon,
  tip,
}

/// One item in the notification list.
/// It stores facts (type, doctor, time) and not text, so the words follow
/// the selected language.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.appointmentId,
    this.doctorId,
    this.dateTime,
    this.serial,
    this.reminderMinutes,
    this.tipIndex,
  });

  final String id;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? appointmentId;
  final String? doctorId;
  final DateTime? dateTime;
  final int? serial;
  final int? reminderMinutes;
  final int? tipIndex;

  bool get isAboutAppointment => appointmentId != null;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      appointmentId: appointmentId,
      doctorId: doctorId,
      dateTime: dateTime,
      serial: serial,
      reminderMinutes: reminderMinutes,
      tipIndex: tipIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'created_at': createdAt.toIso8601String(),
    'is_read': isRead,
    'appointment_id': appointmentId,
    'doctor_id': doctorId,
    'date_time': dateTime?.toIso8601String(),
    'serial': serial,
    'reminder_minutes': reminderMinutes,
    'tip_index': tipIndex,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final dateText = json['date_time'] as String?;
    return AppNotification(
      id: json['id'] as String,
      type: NotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NotificationType.tip,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: (json['is_read'] as bool?) ?? false,
      appointmentId: json['appointment_id'] as String?,
      doctorId: json['doctor_id'] as String?,
      dateTime: dateText == null ? null : DateTime.parse(dateText),
      serial: (json['serial'] as num?)?.toInt(),
      reminderMinutes: (json['reminder_minutes'] as num?)?.toInt(),
      tipIndex: (json['tip_index'] as num?)?.toInt(),
    );
  }
}
