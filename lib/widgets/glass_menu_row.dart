import 'package:flutter/material.dart';

import '../app/color.dart';

/// One tappable row in a menu card: icon, label, optional value and arrow.
class GlassMenuRow extends StatelessWidget {
  const GlassMenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.color = AppColors.onGlass,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? value;
  final Color color;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (value != null)
                  Text(
                    value!,
                    style: const TextStyle(
                      color: AppColors.onGlassMuted,
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.onGlassMuted,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 52, color: AppColors.glassBorder),
      ],
    );
  }
}
