import 'package:curely/app/color.dart';
import 'package:flutter/material.dart';


/// Page dots for PageView (glass design). The active dot is wider.
class DotIndicator extends StatelessWidget {
  const DotIndicator({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 26 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.onGlass
                : AppColors.onGlass.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
