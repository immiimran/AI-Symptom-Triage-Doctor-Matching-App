import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../models/appointment_model.dart';
import '../../models/doctor_model.dart';
import '../../models/time_slot.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/slot_service.dart';
import '../../texts/app_texts.dart';
import '../../utils/date_utils.dart';
import '../../widgets/doctor_mini_card.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/glass_section_title.dart';
import '../booking/booking_summary_card.dart';
import '../booking/date_strip.dart';
import '../booking/time_slot_picker.dart';

/// Move an upcoming appointment to a new date and time (new serial).
class RescheduleScreen extends StatefulWidget {
  const RescheduleScreen({super.key});

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  final SlotService _slotService = SlotService();

  DateTime? _date;
  TimeSlot? _slot;
  String? _period;
  bool _saving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final appointments = context.read<AppointmentProvider>();
    final doctors = context.read<DoctorProvider>();
    final args = ModalRoute.of(context)?.settings.arguments;
    final appointment = args is String ? appointments.byId(args) : null;
    final doctor = appointment == null
        ? null
        : doctors.doctorById(appointment.doctorId);
    if (doctor != null) {
      _date = _slotService.firstDateWithSlots(
        doctor: doctor,
        isBookedByUser: (s) => appointments.isSlotTaken(doctor.id, s),
      );
    }
  }

  void _showMessage(String key) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t(key))));
  }

  Future<void> _confirm(
    AppointmentModel appointment,
    DoctorModel doctor,
  ) async {
    final slot = _slot;
    if (slot == null) {
      _showMessage('select_slot_first');
      return;
    }

    final appointments = context.read<AppointmentProvider>();
    if (appointments.isSlotTaken(doctor.id, slot.start)) {
      setState(() => _slot = null);
      _showMessage('slot_just_taken');
      return;
    }

    setState(() => _saving = true);
    try {
      final reminder = await appointments.reschedule(
        appointment: appointment,
        doctor: doctor,
        newDateTime: slot.start,
        newSerial: slot.serial,
      );
      if (!mounted) return;

      final messageKey = reminder == null
          ? 'reschedule_done'
          : reminder == ReminderResult.set
          ? 'reschedule_done_reminder_kept'
          : 'reschedule_done_reminder_off';
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t(messageKey))));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('booking_failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final doctors = context.watch<DoctorProvider>();
    final appointments = context.watch<AppointmentProvider>();

    final args = ModalRoute.of(context)?.settings.arguments;
    final appointment = args is String ? appointments.byId(args) : null;
    final doctor = appointment == null
        ? null
        : doctors.doctorById(appointment.doctorId);

    if (appointment == null ||
        doctor == null ||
        appointment.status != AppointmentStatus.upcoming) {
      return GlassScaffold(
        title: t('reschedule_title'),
        body: Center(
          child: Text(
            t('reschedule_not_possible'),
            style: const TextStyle(color: AppColors.onGlass),
          ),
        ),
      );
    }

    final date = _date;
    final slots = date == null
        ? <TimeSlot>[]
        : _slotService
              .slotsFor(
                doctor: doctor,
                date: date,
                isBookedByUser: (s) => appointments.isSlotTaken(doctor.id, s),
              )
              .where((s) => !s.isPast)
              .toList();

    return GlassScaffold(
      title: t('reschedule_title'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          DoctorMiniCard(
            doctor: doctor,
            specialtyName: doctors.specialtyName(doctor.specialtyId),
          ),
          const SizedBox(height: 14),
          GlassCard(
            blur: false,
            radius: 18,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.event_rounded, color: AppColors.sphereRose),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('reschedule_current'),
                        style: const TextStyle(
                          color: AppColors.onGlassMuted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${AppDateUtils.fullDate(appointment.dateTime)} · '
                        '${AppDateUtils.time(appointment.dateTime)} · '
                        '#${appointment.serialNumber}',
                        style: const TextStyle(
                          color: AppColors.onGlass,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          GlassSectionTitle(t('select_date')),
          const SizedBox(height: 12),
          DateStrip(
            doctor: doctor,
            selected: _date,
            onSelected: (value) => setState(() {
              _date = value;
              _slot = null;
              _period = null;
            }),
          ),
          const SizedBox(height: 22),
          GlassSectionTitle(t('select_time')),
          const SizedBox(height: 4),
          Text(
            t('serial_hint'),
            style: const TextStyle(color: AppColors.onGlassMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TimeSlotPicker(
            slots: slots,
            selected: _slot,
            period: _period,
            onPeriodChanged: (value) => setState(() => _period = value),
            onSelected: (slot) => setState(() => _slot = slot),
          ),
          if (_slot != null) ...[
            const SizedBox(height: 22),
            GlassSectionTitle(t('booking_summary')),
            const SizedBox(height: 12),
            BookingSummaryCard(doctor: doctor, slot: _slot!),
          ],
        ],
      ),
      bottom: GlassButton(
        label: t('confirm_reschedule'),
        isLoading: _saving,
        onPressed: () => _confirm(appointment, doctor),
      ),
    );
  }
}
