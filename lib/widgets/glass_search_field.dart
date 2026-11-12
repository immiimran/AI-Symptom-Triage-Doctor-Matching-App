import 'package:flutter/material.dart';

import '../app/color.dart';

/// Search box for glass screens, with a clear button.
class GlassSearchField extends StatelessWidget {
  const GlassSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.glassBorder),
    );

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.onGlass),
          cursorColor: AppColors.onGlass,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassFill,
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.onGlassMuted),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.onGlassMuted,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.onGlassMuted,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(
                color: AppColors.onGlass,
                width: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
