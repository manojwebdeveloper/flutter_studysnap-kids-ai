import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../parent_guard.dart';

/// Wraps Kid Mode screens with the kid-style bottom navigation bar.
/// Intercepts the Android back button and the iOS swipe-back gesture
/// to show the Parent PIN guard before allowing exit to Parent Mode.
class KidShell extends ConsumerStatefulWidget {
  const KidShell({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<KidShell> createState() => _KidShellState();
}

class _KidShellState extends ConsumerState<KidShell> {
  static const _tabs = [
    _KidTab('🏠', 'Home',    AppRoutes.kid),
    _KidTab('🃏', 'Cards',   AppRoutes.flashcards),
    _KidTab('🎯', 'Quiz',    AppRoutes.quiz),
    _KidTab('🏆', 'Rewards', AppRoutes.rewards),
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

    // PopScope intercepts Android back button + iOS back gesture and routes
    // it through the Parent PIN guard instead of exiting Kid Mode.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        showParentGuard(context, ref);
      },
      child: Scaffold(
        backgroundColor: AppColours.kidBackground,
        body: Stack(
          children: [
            Positioned.fill(child: widget.child),
            Positioned(
              left: 14,
              right: 14,
              bottom: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: _tabs.asMap().entries.map((e) {
                    final isOn = idx == e.key;
                    final t = e.value;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.go(t.route),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isOn ? AppColours.kidBlue : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(t.emoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 6),
                                Text(
                                  t.label,
                                  style: GoogleFonts.nunito(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isOn ? Colors.white : AppColours.kidMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KidTab {
  const _KidTab(this.emoji, this.label, this.route);
  final String emoji, label, route;
}
