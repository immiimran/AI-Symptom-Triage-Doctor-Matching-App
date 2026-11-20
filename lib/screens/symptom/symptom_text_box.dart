import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_card.dart';

/// Big glass text box for describing symptoms, with Clear and Speak buttons.
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
    final buttonRadius = BorderRadius.circular(20);

    return GlassCard(
      blur: false,
      radius: 24,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          TextField(
            controller: controller,
            minLines: 5,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: AppColors.onGlass, fontSize: 16),
            cursorColor: AppColors.onGlass,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.onGlassMuted),
              contentPadding: const EdgeInsets.all(18),
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
                        foregroundColor: AppColors.onGlassMuted,
                      ),
                    );
                  },
                ),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: buttonRadius,
                    onTap: onMicTap,
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: buttonRadius,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.glassButtonStart,
                            AppColors.glassButtonEnd,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.mic_rounded,
                            color: AppColors.onGlass,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t('tap_to_speak'),
                            style: const TextStyle(
                              color: AppColors.onGlass,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
