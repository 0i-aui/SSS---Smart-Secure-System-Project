// lib/presentation/screens/home_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../services/alert_service.dart';
import 'dashboard/dashboard_screen.dart';
import 'bluetooth/bluetooth_screen.dart';
import 'history/history_screen.dart';
import 'settings/settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  void _goToHistory() {
    setState(() => _currentIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    final alert = context.watch<AlertService>();
    final hasActiveAlerts =
        alert.activeMotionAlert != null || alert.activeSmokeAlert != null;

    final pages = [
      DashboardScreen(onNavigateToHistory: _goToHistory),
      const BluetoothScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _CyberNavBar(
        currentIndex: _currentIndex,
        hasAlerts: hasActiveAlerts,
        historyCount: alert.history.length,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _CyberNavBar extends StatelessWidget {
  final int currentIndex;
  final bool hasAlerts;
  final int historyCount;
  final ValueChanged<int> onTap;

  const _CyberNavBar({
    required this.currentIndex,
    required this.hasAlerts,
    required this.historyCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                selected: currentIndex == 0,
                badge: hasAlerts,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.bluetooth_outlined,
                activeIcon: Icons.bluetooth_connected,
                label: 'Bluetooth',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'History',
                selected: currentIndex == 2,
                count: historyCount > 0 ? historyCount : null,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                selected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final bool badge;
  final int? count;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = false,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.neonBlue : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.neonBlue.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.neonBlue.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  color: color,
                  size: 22,
                ),
                if (badge)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.alertRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (count != null && count! > 0 && !badge)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.neonBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count! > 99 ? '99+' : count.toString(),
                        style: const TextStyle(
                          color: AppColors.bgDeep,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
