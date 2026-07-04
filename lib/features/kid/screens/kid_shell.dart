import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';

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

  /// Shows the PIN guard modal. Returns true if PIN was correct.
  Future<bool> _showPinGuard(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ParentPinGuard(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);

    // PopScope intercepts Android back button + iOS back gesture
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _showPinGuard(context);
        if (ok && context.mounted) context.go(AppRoutes.parent);
      },
      child: Scaffold(
        backgroundColor: AppColours.kidBg,
        body: widget.child,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE0F2FE), width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: _tabs.asMap().entries.map((e) {
                  final isOn = idx == e.key;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => context.go(_tabs[e.key].route),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_tabs[e.key].emoji,
                            style: TextStyle(fontSize: isOn ? 24 : 22)),
                          const SizedBox(height: 3),
                          Text(_tabs[e.key].label,
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isOn ? AppColours.kidBlue : AppColours.textMuted,
                            )),
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
    );
  }
}

// ─────────────────────────────────────────────────────────
// Parent PIN Guard — bottom sheet modal
// ─────────────────────────────────────────────────────────

class _ParentPinGuard extends ConsumerStatefulWidget {
  const _ParentPinGuard();

  @override
  ConsumerState<_ParentPinGuard> createState() => _ParentPinGuardState();
}

class _ParentPinGuardState extends ConsumerState<_ParentPinGuard> {
  String _pin      = '';
  bool   _hasError = false;
  bool   _loading  = false;

  void _tapDigit(String digit) {
    if (_pin.length >= 4 || _loading) return;
    HapticFeedback.lightImpact();
    setState(() { _pin += digit; _hasError = false; });
    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 180), _verify);
    }
  }

  void _backspace() {
    if (_pin.isEmpty || _loading) return;
    HapticFeedback.lightImpact();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    setState(() => _loading = true);

    // Try biometrics first
    final authRepo = ref.read(authRepositoryProvider);
    final bioResult = await authRepo.authenticateWithBiometrics();
    if (bioResult.dataOrNull == true) {
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    // Fall back to PIN
    final pinResult = await authRepo.verifyPin(_pin);
    final correct = pinResult.dataOrNull ?? false;

    if (mounted) {
      if (correct) {
        Navigator.of(context).pop(true);
      } else {
        HapticFeedback.heavyImpact();
        setState(() { _pin = ''; _hasError = true; _loading = false; });
      }
    }
  }

  Future<void> _tryBiometrics() async {
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.authenticateWithBiometrics();
    if ((result.dataOrNull ?? false) && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Handle bar
              Container(
                width: 38, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColours.line,
                  borderRadius: BorderRadius.circular(99)),
              ),

              // Lock icon
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppColours.blueLight,
                  borderRadius: BorderRadius.circular(18)),
                child: const Center(child: Text('🔒', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(height: 14),

              // Title
              const Text('Parent Mode',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                  color: AppColours.textDark, letterSpacing: -0.3)),
              const SizedBox(height: 6),
              Text(
                _hasError
                    ? 'Wrong PIN — try again'
                    : 'Enter your PIN to exit Kid Mode',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: _hasError ? AppColours.red : AppColours.textMuted),
              ),
              const SizedBox(height: 22),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _pin.length
                        ? (_hasError ? AppColours.red : AppColours.blue)
                        : Colors.transparent,
                    border: Border.all(
                      color: _hasError ? AppColours.red : AppColours.blue,
                      width: 2),
                  ),
                )),
              ),
              const SizedBox(height: 24),

              // Number pad
              SizedBox(
                height: 240,
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 1.6,
                  children: [
                    ...['1','2','3','4','5','6','7','8','9'].map(
                        (d) => _PinKey(label: d, onTap: () => _tapDigit(d))),
                    // Face ID / biometrics
                    _PinKey(
                      label: '󰍿',
                      icon: const Icon(Icons.face, size: 26, color: AppColours.textDark),
                      onTap: _tryBiometrics,
                    ),
                    _PinKey(label: '0', onTap: () => _tapDigit('0')),
                    _PinKey(
                      label: '⌫',
                      onTap: _backspace,
                      fontSize: 22,
                    ),
                  ],
                ),
              ),

              // Cancel
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColours.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PIN key button ─────────────────────────────────────────

class _PinKey extends StatefulWidget {
  const _PinKey({
    required this.onTap,
    this.label = '',
    this.icon,
    this.fontSize = 30,
  });
  final VoidCallback onTap;
  final String label;
  final Widget? icon;
  final double fontSize;

  @override
  State<_PinKey> createState() => _PinKeyState();
}

class _PinKeyState extends State<_PinKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _pressed ? AppColours.subtle : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: widget.icon ?? Text(
            widget.label,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w400,
              color: AppColours.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _KidTab {
  const _KidTab(this.emoji, this.label, this.route);
  final String emoji, label, route;
}
