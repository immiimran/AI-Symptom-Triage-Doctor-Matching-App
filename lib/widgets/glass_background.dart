import 'package:flutter/material.dart';

import '../app/color.dart';

/// Dark gradient background with two soft spheres (glassmorphism style).
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.authBgTop,
            AppColors.authBgMid,
            AppColors.authBgBottom,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: -50,
            right: -40,
            child: _Sphere(
              size: 230,
              light: AppColors.sphereRose,
              deep: AppColors.sphereRoseDeep,
            ),
          ),
          const Positioned(
            bottom: -70,
            left: -60,
            child: _Sphere(
              size: 280,
              light: AppColors.sphereSilver,
              deep: AppColors.sphereSilverDeep,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Sphere extends StatelessWidget {
  const _Sphere({required this.size, required this.light, required this.deep});

  final double size;
  final Color light;
  final Color deep;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.5),
          radius: 0.95,
          colors: [light, deep],
        ),
      ),
    );
  }
}
