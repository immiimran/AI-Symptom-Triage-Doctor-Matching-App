enum AppointmentStatus { upcoming, completed, cancelled }

/// A booked appointment. Saved locally (and in Firestore later).
class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientName,
    required this.dateTime,
    required this.serialNumber,
    this.status = AppointmentStatus.upcoming,
    this.note = '',
    this.patientAge,
    this.patientGender = '',
    this.fee = 0,
    this.reminderMinutes,
  });

  final String id;
  final String doctorId;
  final String patientName;
  final DateTime dateTime;
  final int serialNumber;
  final AppointmentStatus status;
  final String note;
  final int? patientAge;

  /// 'male', 'female', 'other' or empty.
  final String patientGender;

  /// Consultation fee at the time of booking.
  final int fee;

  /// Minutes before the appointment for the reminder, or null for none.
  final int? reminderMinutes;

  /// Stable number for the notification, taken from the id's digits.
  int get notificationId {
    final digits = id.replaceAll(RegExp(r'\D'), '');
    final short = digits.length > 9
        ? digits.substring(digits.length - 9)
        : digits;
    return int.tryParse(short) ?? 0;
  }

  AppointmentModel copyWith({
    DateTime? dateTime,
    int? serialNumber,
    AppointmentStatus? status,
    int? reminderMinutes,
    bool clearReminder = false,
  }) {
    return AppointmentModel(
      id: id,
      doctorId: doctorId,
      patientName: patientName,
      dateTime: dateTime ?? this.dateTime,
      serialNumber: serialNumber ?? this.serialNumber,
      status: status ?? this.status,
      note: note,
      patientAge: patientAge,
      patientGender: patientGender,
      fee: fee,
      reminderMinutes: clearReminder
          ? null
          : (reminderMinutes ?? this.reminderMinutes),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'doctor_id': doctorId,
    'patient_name': patientName,
    'date_time': dateTime.toIso8601String(),
    'serial_number': serialNumber,
    'status': status.name,
    'note': note,
    'patient_age': patientAge,
    'patient_gender': patientGender,
    'fee': fee,
    'reminder_minutes': reminderMinutes,
  };

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      patientName: (json['patient_name'] as String?) ?? '',
      dateTime: DateTime.parse(json['date_time'] as String),
      serialNumber: (json['serial_number'] as num?)?.toInt() ?? 0,
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => AppointmentStatus.upcoming,
      ),
      note: (json['note'] as String?) ?? '',
      patientAge: (json['patient_age'] as num?)?.toInt(),
      patientGender: (json['patient_gender'] as String?) ?? '',
      fee: (json['fee'] as num?)?.toInt() ?? 0,
      reminderMinutes: (json['reminder_minutes'] as num?)?.toInt(),
    );
  }
}
