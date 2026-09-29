import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'explore_tab.dart';
import 'library_tab.dart';
import 'settings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const ExploreTab(),
      LibraryTab(onNavigateToExplore: () => _onTabTapped(0)),
      const SettingsTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.accentMuted,
          height: 68,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.explore, color: AppColors.accent),
              label: 'Jelajah',
            ),
            NavigationDestination(
              icon: Icon(Icons.video_library_outlined,
                  color: AppColors.textSecondary),
              selectedIcon:
                  Icon(Icons.video_library, color: AppColors.accent),
              label: 'Koleksi',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.settings, color: AppColors.accent),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
