import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

/// Wraps Parent Mode screens with a persistent bottom navigation bar.
/// Used as the ShellRoute builder in app_router.dart.
class ParentShell extends StatelessWidget {
  const ParentShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    _NavTab(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home',      route: AppRoutes.parent),
    _NavTab(icon: Icons.crop_free,     activeIcon: Icons.crop_free, label: 'Scan', route: AppRoutes.scan),
    _NavTab(icon: Icons.layers_outlined,activeIcon: Icons.layers,  label: 'Study Sets', route: AppRoutes.studySets),
    _NavTab(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Progress', route: AppRoutes.progress),
    _NavTab(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings',  route: AppRoutes.settings),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColours.line, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: idx,
          onTap: (i) => context.go(_tabs[i].route),
          items: _tabs.map((t) => BottomNavigationBarItem(
            icon: Icon(t.icon),
            activeIcon: Icon(t.activeIcon),
            label: t.label,
          )).toList(),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({required this.icon, required this.activeIcon, required this.label, required this.route});
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}
