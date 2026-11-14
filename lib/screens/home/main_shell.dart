import 'package:curely/screens/appoinment/appointments_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../providers/language_provider.dart';
import '../../texts/app_texts.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Main container with the bottom navigation bar.
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
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild labels when the language changes.
    context.watch<LanguageProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          const AppointmentsScreen(),
          const SizedBox.shrink(), // Check tab opens a full screen instead.
          const FavoritesScreen(),
          ProfileScreen(onSwitchTab: _onSelect),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onSelect,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: t('nav_home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: t('nav_appointments'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome_rounded),
            label: t('nav_check'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border_rounded),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: t('nav_favorites'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: t('nav_profile'),
          ),
        ],
      ),
    );
  }
}
