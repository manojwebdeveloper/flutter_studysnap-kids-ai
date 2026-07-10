import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

/// Wraps Parent Mode screens with a persistent bottom navigation bar.
/// Used as the ShellRoute builder in app_router.dart.
class ParentShell extends StatelessWidget {
  const ParentShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    _NavTab(
      label: 'Home',
      route: AppRoutes.parent,
      path: 'M3 11l9-7 9 7v9a2 2 0 01-2 2h-4v-7H9v7H5a2 2 0 01-2-2v-9z',
    ),
    _NavTab(
      label: 'Scan',
      route: AppRoutes.scan,
      path: 'M3 7V5a2 2 0 012-2h2M17 3h2a2 2 0 012 2v2M21 17v2a2 2 0 01-2 2h-2M7 21H5a2 2 0 01-2-2v-2M7 12h10',
    ),
    _NavTab(
      label: 'Study Sets',
      route: AppRoutes.studySets,
      path: 'M4 5a2 2 0 012-2h12a2 2 0 012 2v14l-4-2-4 2-4-2-4 2V5z',
    ),
    _NavTab(
      label: 'Progress',
      route: AppRoutes.progress,
      path: 'M4 19V5M4 19h16M8 15v-4M12 15V8M16 15v-7',
    ),
    _NavTab(
      label: 'Settings',
      route: AppRoutes.settings,
      path: 'M12 8a4 4 0 100 8 4 4 0 000-8zM19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 11-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 11-4 0v-.09A1.65 1.65 0 008 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 11-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82V9a1.65 1.65 0 001-1.51H2a2 2 0 110-4h.09A1.65 1.65 0 004.6 8a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 112.83-2.83l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V2a2 2 0 114 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 112.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H22a2 2 0 110 4h-.09a1.65 1.65 0 00-1.51 1z',
    ),
  ];

  /// Longest-prefix match so a sub-route (e.g. /parent/scan) highlights its own
  /// tab rather than Home. Same routes/navigation as before.
  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    int best = 0;
    int bestLen = -1;
    for (int i = 0; i < _tabs.length; i++) {
      final r = _tabs[i].route;
      if (loc.startsWith(r) && r.length > bestLen) {
        best = i;
        bestLen = r.length;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              border: const Border(top: BorderSide(color: AppColours.line, width: 1)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 62,
                child: Row(
                  children: _tabs.asMap().entries.map((e) {
                    final isOn = idx == e.key;
                    final t = e.value;
                    final c = isOn ? AppColours.blue : AppColours.muted;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.go(t.route),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            appSvg(t.path, size: 24, stroke: c, strokeWidth: 2),
                            const SizedBox(height: 4),
                            Text(
                              t.label,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isOn ? FontWeight.w700 : FontWeight.w500,
                                color: c,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({required this.path, required this.label, required this.route});
  final String path;
  final String label;
  final String route;
}
