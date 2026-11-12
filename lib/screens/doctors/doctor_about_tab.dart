import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../models/doctor_model.dart';
import '../../providers/doctor_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_chip.dart';

/// "About" tab: biography, degrees and quick facts.
class DoctorAboutTab extends StatelessWidget {
  const DoctorAboutTab({
    super.key,
    required this.doctor,
    required this.doctors,
  });

  final DoctorModel doctor;
  final DoctorProvider doctors;

  @override
  Widget build(BuildContext context) {
    final degrees = doctor.degrees
        .split(',')
        .map((d) => d.trim())
        .where((d) => d.isNotEmpty)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        GlassCard(
          blur: false,
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title(t('about_doctor')),
              const SizedBox(height: 8),
              Text(
                doctor.about.isEmpty ? '-' : doctor.about,
                style: const TextStyle(color: AppColors.onGlass, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          blur: false,
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title(t('degrees_title')),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final degree in degrees)
                    GlassChip(label: degree, selected: false, onTap: () {}),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          blur: false,
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title(t('quick_facts')),
              const SizedBox(height: 12),
              _Fact(
                label: doctors.specialtyName(doctor.specialtyId),
                icon: Icons.medical_services_outlined,
              ),
              _Fact(
                label: '${doctor.experienceYears} ${t('years_experience')}',
                icon: Icons.workspace_premium_outlined,
              ),
              _Fact(
                label: '${doctor.patientCount} ${t('patients_treated')}',
                icon: Icons.groups_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.onGlass,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.onGlassMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.onGlass),
            ),
          ),
        ],
      ),
    );
  }
}
