import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_icon_button.dart';

/// Big glass call-to-action card: write (or speak) your symptoms.
class SymptomCheckCard extends StatelessWidget {
  const SymptomCheckCard({
    super.key,
    required this.onTap,
    required this.onMicTap,
  });

  final VoidCallback onTap;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.glassBorder),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.sphereRose.withValues(alpha: 0.38),
                AppColors.glassButtonEnd.withValues(alpha: 0.55),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -34,
                top: -34,
                child: _Circle(size: 140, alpha: 0.12),
              ),
              Positioned(
                right: 60,
                bottom: -70,
                child: _Circle(size: 130, alpha: 0.08),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.onGlass,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t('symptom_card_title'),
                            style: const TextStyle(
                              color: AppColors.onGlass,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t('symptom_card_subtitle'),
                      style: TextStyle(
                        color: AppColors.onGlass.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton(
                            label: t('symptom_card_button'),
                            onPressed: onTap,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GlassIconButton(
                          icon: Icons.mic_rounded,
                          onTap: onMicTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}
