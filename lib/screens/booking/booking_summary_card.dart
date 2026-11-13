import 'package:flutter/material.dart';

import '../../app/constants.dart';
import '../../models/doctor_model.dart';
import '../../models/time_slot.dart';
import '../../texts/app_texts.dart';
import '../../utils/date_utils.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_info_row.dart';

/// Shows what the user is about to book: hospital, date, time, serial, fee.
class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({
    super.key,
    required this.doctor,
    required this.slot,
  });

  final DoctorModel doctor;
  final TimeSlot slot;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassInfoRow(
            icon: Icons.local_hospital_outlined,
            label: t('hospital'),
            value: doctor.hospital,
          ),
          GlassInfoRow(
            icon: Icons.calendar_today_outlined,
            label: t('summary_date'),
            value: AppDateUtils.fullDate(slot.start),
          ),
          GlassInfoRow(
            icon: Icons.access_time_rounded,
            label: t('summary_time'),
            value: AppDateUtils.time(slot.start),
          ),
          GlassInfoRow(
            icon: Icons.confirmation_number_outlined,
            label: t('summary_serial'),
            value: '#${slot.serial}',
          ),
          GlassInfoRow(
            icon: Icons.payments_outlined,
            label: t('consultation_fee'),
            value: '${AppConstants.currencySymbol}${doctor.fee}',
            isLast: true,
          ),
        ],
      ),
    );
  }
}