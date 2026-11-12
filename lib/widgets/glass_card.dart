import 'dart:ui';

import 'package:flutter/material.dart';

import '../app/color.dart';

/// Frosted-glass card. Set [blur] to false for list items (faster scrolling).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 32, 24, 24),
    this.blur = true,
    this.radius = 28,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool blur;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    Widget content = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.glassBorder),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.glassGradientStart, AppColors.glassGradientEnd],
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (blur) {
      content = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: content,
      );
    }
    return ClipRRect(borderRadius: borderRadius, child: content);
  }
}
