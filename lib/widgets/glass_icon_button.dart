import 'package:flutter/material.dart';

import '../app/color.dart';

/// Round frosted icon button (back, favorite, filter, call).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = AppColors.onGlass,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  /// Small dot, e.g. when filters are active.
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glassFill,
      shape: const CircleBorder(side: BorderSide(color: AppColors.glassBorder)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              if (showBadge)
                Positioned(
                  top: 10,
                  right: 11,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.sphereRose,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
