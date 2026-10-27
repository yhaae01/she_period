import 'package:flutter/material.dart';

import 'data/cycle_repository.dart';
import 'dashboard_page.dart';
import 'pages/calendar_page.dart';
import 'pages/settings_page.dart';
import 'services/notification_service.dart';
import 'theme/pink_theme.dart';

/// Navigasi utama: Beranda (dashboard) & Kalender.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.repository});

  final CycleRepository repository;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    widget.repository.addListener(_syncNotifications);
    _syncNotifications();
  }

  @override
  void dispose() {
    widget.repository.removeListener(_syncNotifications);
    super.dispose();
  }

  /// Jadwal pengingat ikut diperbarui setiap data siklus berubah.
  void _syncNotifications() {
    NotificationService.instance.syncFrom(widget.repository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardPage(repository: widget.repository),
          CalendarPage(repository: widget.repository),
          SettingsPage(repository: widget.repository),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        backgroundColor: PinkPalette.white,
        indicatorColor: PinkPalette.blush,
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.favorite_border, color: PinkPalette.dustyRose),
            selectedIcon: Icon(Icons.favorite, color: PinkPalette.deepRose),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.calendar_month_outlined, color: PinkPalette.dustyRose),
            selectedIcon: Icon(Icons.calendar_month, color: PinkPalette.deepRose),
            label: 'Kalender',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: PinkPalette.dustyRose),
            selectedIcon: Icon(Icons.settings, color: PinkPalette.deepRose),
            label: 'Atur',
          ),
        ],
      ),
    );
  }
}