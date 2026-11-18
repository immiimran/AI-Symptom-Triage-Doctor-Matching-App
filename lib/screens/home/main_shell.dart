import 'package:curely/screens/appoinment/appointments_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../providers/language_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_nav_bar.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Main container: the tabs and the floating glass bottom bar.
/// The middle "Check" button opens the symptom screen as a full page.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _checkIndex = 2;

  int _index = 0;

  void _onSelect(int index) {
    if (index == _checkIndex) {
      Navigator.of(context).pushNamed(AppRoutes.symptom);
      return;
    }
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild labels when the language changes.
    context.watch<LanguageProvider>();

    final items = [
      GlassNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: t('nav_home'),
      ),
      GlassNavItem(
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        label: t('nav_appointments'),
      ),
      GlassNavItem(
        icon: Icons.auto_awesome_outlined,
        selectedIcon: Icons.auto_awesome_rounded,
        label: t('nav_check'),
      ),
      GlassNavItem(
        icon: Icons.favorite_border_rounded,
        selectedIcon: Icons.favorite_rounded,
        label: t('nav_favorites'),
      ),
      GlassNavItem(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: t('nav_profile'),
      ),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.authBgTop,
      body: _TabStack(
        index: _index,
        children: [
          HomeScreen(onSwitchTab: _onSelect),
          const AppointmentsScreen(),
          const SizedBox.shrink(), // Check tab opens a full screen instead.
          const FavoritesScreen(),
          ProfileScreen(onSwitchTab: _onSelect),
        ],
      ),
      bottomNavigationBar: GlassNavBar(
        items: items,
        selectedIndex: _index,
        centerIndex: _checkIndex,
        onSelected: _onSelect,
      ),
    );
  }
}

/// Keeps every tab alive and cross-fades between them with a small slide.
class _TabStack extends StatelessWidget {
  const _TabStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < children.length; i++)
          _TabPage(visible: i == index, child: children[i]),
      ],
    );
  }
}

class _TabPage extends StatelessWidget {
  const _TabPage({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: visible ? Offset.zero : const Offset(0, 0.02),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: child,
          ),
        ),
      ),
    );
  }
}
