import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/assets.dart';
import '../../app/color.dart';
import '../../app/constants.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_background.dart';

/// First screen shown on launch (glass design).
/// Plays a short logo animation, checks the login state, then opens
/// Home (logged in) or Onboarding (not logged in).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.splashAnimation,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _navigateNext();
  }

  /// Waits for the minimum splash time and the auth check, then navigates.
  Future<void> _navigateNext() async {
    final auth = context.read<AuthProvider>();

    await Future.wait([
      auth.checkAuthStatus(),
      Future<void>.delayed(AppConstants.splashDuration),
    ]);

    if (!mounted) return;

    final nextRoute = auth.isLoggedIn ? AppRoutes.home : AppRoutes.onboarding;
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        showSilverSphere: false,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 124,
                          height: 124,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(34),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.glassButtonStart.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 40,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              AppAssets.logoMarkPng,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t('app_name'),
                          style: const TextStyle(
                            color: AppColors.onGlass,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            t('splash_tagline'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.onGlassMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.onGlass,
                    ),
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
