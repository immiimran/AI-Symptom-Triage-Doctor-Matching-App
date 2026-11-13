import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../texts/app_texts.dart';
import '../../utils/validators.dart';
import '../../widgets/glass_chip.dart';
import '../../widgets/glass_text_field.dart';

/// Patient name, age, gender and reason for the visit.
class PatientDetailsForm extends StatelessWidget {
  const PatientDetailsForm({
    super.key,
    required this.nameController,
    required this.ageController,
    required this.noteController,
    required this.gender,
    required this.onGenderChanged,
  });

  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController noteController;

  /// 'male', 'female', 'other' or empty.
  final String gender;
  final ValueChanged<String> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    final options = <(String, String)>[
      ('male', t('gender_male')),
      ('female', t('gender_female')),
      ('other', t('gender_other')),
    ];

    return Column(
      children: [
        GlassTextField(
          label: t('patient_name'),
          controller: nameController,
          icon: Icons.person_outline_rounded,
          validator: Validators.name,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        GlassTextField(
          label: t('patient_age'),
          controller: ageController,
          icon: Icons.cake_outlined,
          validator: Validators.age,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            t('patient_gender'),
            style: const TextStyle(
              color: AppColors.onGlass,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                GlassChip(
                  label: option.$2,
                  selected: gender == option.$1,
                  // Tap again to clear.
                  onTap: () =>
                      onGenderChanged(gender == option.$1 ? '' : option.$1),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassTextField(
          label: t('visit_reason'),
          controller: noteController,
          icon: Icons.notes_rounded,
          maxLines: 3,
        ),
      ],
    );
  }
}
