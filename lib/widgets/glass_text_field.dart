import 'package:flutter/material.dart';

import '../app/color.dart';

/// Text field styled for glass screens: label above, translucent fill,
/// leading icon, and a show/hide toggle for passwords.
class GlassTextField extends StatefulWidget {
  const GlassTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.validator,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.onGlass,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          autofillHints: widget.autofillHints,
          obscureText: widget.isPassword && _obscure,
          style: const TextStyle(color: AppColors.onGlass),
          cursorColor: AppColors.onGlass,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassFill,
            prefixIcon: Icon(widget.icon, color: AppColors.onGlassMuted),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.onGlassMuted,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: border(AppColors.glassBorder),
            enabledBorder: border(AppColors.glassBorder),
            focusedBorder: border(AppColors.onGlass, 1.5),
            errorBorder: border(AppColors.onGlassError),
            focusedErrorBorder: border(AppColors.onGlassError, 1.5),
            errorStyle: const TextStyle(color: AppColors.onGlassError),
          ),
        ),
      ],
    );
  }
}
