import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../texts/app_texts.dart';

/// Big text box for describing symptoms, with Clear and Speak buttons.
class SymptomTextBox extends StatelessWidget {
  const SymptomTextBox({
    super.key,
    required this.controller,
    required this.hint,
    required this.onMicTap,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onMicTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            minLines: 5,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 12, 12),
            child: Row(
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return TextButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: Text(t('clear')),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                      ),
                    );
                  },
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: onMicTap,
                  icon: const Icon(Icons.mic_rounded),
                  label: Text(t('tap_to_speak')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
