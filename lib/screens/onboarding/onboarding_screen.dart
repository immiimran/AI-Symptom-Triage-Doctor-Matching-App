import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../models/onboarding_item.dart';
import '../../providers/language_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/dot_indicator.dart';
import '../../widgets/glass_background.dart';
import '../../widgets/glass_button.dart';
import 'onboarding_setup_page.dart';
import 'onboarding_slide.dart';

/// Intro screen (glass design): three slides, then language choice and
/// the medical disclaimer.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.edit_note_rounded,
      titleKey: 'onb1_title',
      descriptionKey: 'onb1_desc',
    ),
    OnboardingItem(
      icon: Icons.auto_awesome_rounded,
      titleKey: 'onb2_title',
      descriptionKey: 'onb2_desc',
    ),
    OnboardingItem(
      icon: Icons.event_available_rounded,
      titleKey: 'onb3_title',
      descriptionKey: 'onb3_desc',
    ),
  ];

  static const Duration _pageDuration = Duration(milliseconds: 350);

  final PageController _controller = PageController();
  int _page = 0;
  bool _accepted = false;

  /// Intro slides plus one final setup page.
  int get _pageCount => _items.length + 1;
  int get _lastIndex => _pageCount - 1;
  bool get _isLastPage => _page == _lastIndex;

  void _next() {
    _controller.nextPage(duration: _pageDuration, curve: Curves.easeOutCubic);
  }

  void _skip() {
    _controller.animateToPage(
      _lastIndex,
      duration: _pageDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild the whole screen when the language changes.
    context.watch<LanguageProvider>();

    // The last page needs the disclaimer to be accepted first.
    final canContinue = !_isLastPage || _accepted;

    return Scaffold(
      body: GlassBackground(
        showSilverSphere: false,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _isLastPage
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: TextButton(
                            onPressed: _skip,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.onGlassMuted,
                            ),
                            child: Text(t('onboarding_skip')),
                          ),
                        ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) => setState(() => _page = index),
                  children: [
                    for (final item in _items) OnboardingSlide(item: item),
                    OnboardingSetupPage(
                      accepted: _accepted,
                      onAcceptedChanged: (value) =>
                          setState(() => _accepted = value),
                    ),
                  ],
                ),
              ),
              DotIndicator(count: _pageCount, index: _page),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: canContinue ? 1 : 0.45,
                  child: GlassButton(
                    label: _isLastPage
                        ? t('get_started')
                        : t('onboarding_next'),
                    onPressed: canContinue
                        ? (_isLastPage ? _finish : _next)
                        : null,
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
