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
  });

  final String id;
  final String doctorId;
  final String patientName;
  final DateTime dateTime;
  final int serialNumber;
  final AppointmentStatus status;
  final String note;

  AppointmentModel copyWith({DateTime? dateTime, AppointmentStatus? status}) {
    return AppointmentModel(
      id: id,
      doctorId: doctorId,
      patientName: patientName,
      dateTime: dateTime ?? this.dateTime,
      serialNumber: serialNumber,
      status: status ?? this.status,
      note: note,
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
    );
  }
}
