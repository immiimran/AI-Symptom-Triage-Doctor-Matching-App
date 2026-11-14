import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../models/doctor_model.dart';
import '../../models/time_slot.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/triage_provider.dart';
import '../../services/slot_service.dart';
import '../../texts/app_texts.dart';
import '../../widgets/doctor_mini_card.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/glass_section_title.dart';
import 'booking_summary_card.dart';
import 'date_strip.dart';
import 'patient_details_form.dart';
import 'time_slot_picker.dart';

/// Booking: choose a date and a time (= serial), enter patient details,
/// confirm. Then the success screen opens.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _noteController = TextEditingController();
  final SlotService _slotService = SlotService();

  DateTime? _date;
  TimeSlot? _slot;
  String? _period;
  String _gender = '';
  bool _saving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final doctors = context.read<DoctorProvider>();
    final appointments = context.read<AppointmentProvider>();
    final args = ModalRoute.of(context)?.settings.arguments;
    final doctor = args is String ? doctors.doctorById(args) : null;

    // Start on the first date when the doctor sits and still has a free time.
    if (doctor != null) {
      _date = _slotService.firstDateWithSlots(
        doctor: doctor,
        isBookedByUser: (s) => appointments.isSlotTaken(doctor.id, s),
      );
    }

    _nameController.text = context.read<AuthProvider>().userName;

    // Use the symptoms from a recent AI check as the reason for the visit.
    final last = context.read<TriageProvider>().lastResult;
    if (last != null &&
        DateTime.now().difference(last.createdAt) < const Duration(hours: 2)) {
      _noteController.text = last.input.text;
    }
  }

  void _showMessage(String key) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t(key))));
  }

  Future<void> _confirm(DoctorModel doctor) async {
    if (!_formKey.currentState!.validate()) return;

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

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final appointment = await appointments.book(
        doctor: doctor,
        dateTime: slot.start,
        serialNumber: slot.serial,
        patientName: _nameController.text,
        patientAge: int.parse(_ageController.text.trim()),
        patientGender: _gender,
        note: _noteController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.bookingSuccess,
        arguments: appointment.id,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('booking_failed');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final doctors = context.watch<DoctorProvider>();
    final appointments = context.watch<AppointmentProvider>();

    final args = ModalRoute.of(context)?.settings.arguments;
    final doctor = args is String ? doctors.doctorById(args) : null;

    if (doctor == null) {
      return GlassScaffold(
        title: t('booking_title'),
        body: Center(
          child: Text(
            t('doctor_not_found'),
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
      title: t('booking_title'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            DoctorMiniCard(
              doctor: doctor,
              specialtyName: doctors.specialtyName(doctor.specialtyId),
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
              style: const TextStyle(
                color: AppColors.onGlassMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            TimeSlotPicker(
              slots: slots,
              selected: _slot,
              period: _period,
              onPeriodChanged: (value) => setState(() => _period = value),
              onSelected: (slot) => setState(() => _slot = slot),
            ),
            const SizedBox(height: 22),
            GlassSectionTitle(t('patient_details')),
            const SizedBox(height: 12),
            PatientDetailsForm(
              nameController: _nameController,
              ageController: _ageController,
              noteController: _noteController,
              gender: _gender,
              onGenderChanged: (value) => setState(() => _gender = value),
            ),
            if (_slot != null) ...[
              const SizedBox(height: 22),
              GlassSectionTitle(t('booking_summary')),
              const SizedBox(height: 12),
              BookingSummaryCard(doctor: doctor, slot: _slot!),
            ],
          ],
        ),
      ),
      bottom: GlassButton(
        label: t('confirm_booking'),
        isLoading: _saving,
        onPressed: () => _confirm(doctor),
      ),
    );
  }
}
