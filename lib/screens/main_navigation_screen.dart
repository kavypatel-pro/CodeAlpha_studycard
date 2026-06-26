import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'flashcards/flashcard_list_screen.dart';
import 'categories/categories_screen.dart';
import 'statistics/statistics_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialTab;

  const MainNavigationScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  // The 5 tabs list
  final List<Widget> _screens = [
    const HomeScreen(),
    const FlashcardListScreen(),
    const CategoriesScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _screens[_selectedTab],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        elevation: 8,
        shadowColor: Colors.black45,
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFF161522)
            : Colors.white,
        indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.15),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined,
                color: theme.colorScheme.onSurfaceVariant),
            selectedIcon:
                Icon(Icons.home_rounded, color: theme.colorScheme.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined,
                color: theme.colorScheme.onSurfaceVariant),
            selectedIcon:
                Icon(Icons.style_rounded, color: theme.colorScheme.primary),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined,
                color: theme.colorScheme.onSurfaceVariant),
            selectedIcon:
                Icon(Icons.folder_rounded, color: theme.colorScheme.primary),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined,
                color: theme.colorScheme.onSurfaceVariant),
            selectedIcon:
                Icon(Icons.analytics_rounded, color: theme.colorScheme.primary),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded,
                color: theme.colorScheme.onSurfaceVariant),
            selectedIcon:
                Icon(Icons.person_rounded, color: theme.colorScheme.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
