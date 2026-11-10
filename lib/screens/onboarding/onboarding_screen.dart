import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../models/onboarding_item.dart';
import '../../providers/language_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/dot_indicator.dart';
import '../../widgets/primary_button.dart';
import 'onboarding_setup_page.dart';
import 'onboarding_slide.dart';

/// Intro screen: three slides, then language choice and medical disclaimer.
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

  static const Duration _pageDuration = Duration(milliseconds: 300);

  final PageController _controller = PageController();
  int _page = 0;
  bool _accepted = false;

  /// Intro slides plus one final setup page.
  int get _pageCount => _items.length + 1;
  int get _lastIndex => _pageCount - 1;
  bool get _isLastPage => _page == _lastIndex;

  void _next() {
    _controller.nextPage(duration: _pageDuration, curve: Curves.easeOut);
  }

  void _skip() {
    _controller.animateToPage(
      _lastIndex,
      duration: _pageDuration,
      curve: Curves.easeOut,
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

    return Scaffold(
      body: SafeArea(
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
                          child: Text(t('onboarding_skip')),
                        ),
                      ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
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
              child: PrimaryButton(
                label: _isLastPage ? t('get_started') : t('onboarding_next'),
                onPressed: _isLastPage ? (_accepted ? _finish : null) : _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
