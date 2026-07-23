import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

/// Presents the Parent PIN guard from anywhere in Kid Mode.
///
/// - If **no** parent PIN has been set, the child is not trapped — they are
///   sent to the PIN setup screen to create one.
/// - Otherwise a modal bottom sheet asks for the PIN (with a biometric
///   option). A correct PIN (or a successful biometric) exits to Parent Mode.
Future<void> showParentGuard(BuildContext context, WidgetRef ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  final hasPin = await authRepo.hasPin();
  if (!context.mounted) return;

  if (!hasPin) {
    // Don't trap the child behind a guard they can't pass — let them set one.
    context.go(AppRoutes.parentPin);
    return;
  }

  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ParentGuardSheet(),
  );
  if (ok == true && context.mounted) {
    context.go(AppRoutes.parent);
  }
}

/// A small, always-reachable lock button for Kid Mode headers. Tapping it
/// opens the Parent PIN guard. Has a 48×48 touch target.
class KidLockButton extends ConsumerWidget {
  const KidLockButton({super.key, this.light = false});

  /// Set true on light-coloured headers (e.g. Rewards) so the button stays
  /// visible; the default suits the gradient headers.
  final bool light;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: 'Exit Kid Mode',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showParentGuard(context, ref),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: light ? Colors.white : Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: light ? Border.all(color: AppColours.line) : null,
              ),
              child: Icon(Icons.lock_outline,
                  color: light ? AppColours.kidInk : Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps a Kid Mode screen so the Android back button and the iOS back gesture
/// trigger the Parent PIN guard instead of silently exiting Kid Mode.
class KidGuard extends ConsumerWidget {
  const KidGuard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        showParentGuard(context, ref);
      },
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────
// Parent PIN Guard — bottom sheet modal
// ─────────────────────────────────────────────────────────

class ParentGuardSheet extends ConsumerStatefulWidget {
  const ParentGuardSheet({super.key});

  @override
  ConsumerState<ParentGuardSheet> createState() => _ParentGuardSheetState();
}

class _ParentGuardSheetState extends ConsumerState<ParentGuardSheet> {
  String _pin = '';
  bool _hasError = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Offer biometrics first, if the device supports them.
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometrics());
  }

  void _tapDigit(String digit) {
    if (_pin.length >= 4 || _loading) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin += digit; // append exactly once — one dot per tap
      _hasError = false;
    });
    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 120), _verifyPin);
    }
  }

  void _backspace() {
    if (_pin.isEmpty || _loading) return;
    HapticFeedback.lightImpact();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verifyPin() async {
    if (_pin.length != 4) return;
    setState(() => _loading = true);
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.verifyPin(_pin);
    final correct = result.dataOrNull ?? false;
    if (!mounted) return;
    if (correct) {
      Navigator.of(context).pop(true);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _pin = '';
        _hasError = true;
        _loading = false;
      });
    }
  }

  Future<void> _tryBiometrics() async {
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.authenticateWithBiometrics();
    if ((result.dataOrNull ?? false) && mounted) {
      Navigator.of(context).pop(true);
    }
    // Failure / unavailable → stay on the PIN pad, no error shown.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: AppColours.line, borderRadius: BorderRadius.circular(99)),
              ),
              // Lock icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: AppColours.blueLight, borderRadius: BorderRadius.circular(18)),
                child: const Center(child: Text('🔒', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(height: 14),
              // Title
              const Text('Parent Mode',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColours.textDark, letterSpacing: -0.3)),
              const SizedBox(height: 6),
              Text(
                _hasError ? 'Wrong PIN — try again' : 'Enter your PIN to exit Kid Mode',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _hasError ? AppColours.red : AppColours.textMuted),
              ),
              const SizedBox(height: 22),
              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _pin.length ? (_hasError ? AppColours.red : AppColours.blue) : Colors.transparent,
                        border: Border.all(color: _hasError ? AppColours.red : AppColours.blue, width: 2),
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
                    ...['1', '2', '3', '4', '5', '6', '7', '8', '9']
                        .map((d) => _PinKey(label: d, onTap: () => _tapDigit(d))),
                    // Face ID / fingerprint
                    _PinKey(
                      icon: const Icon(Icons.fingerprint, size: 26, color: AppColours.textDark),
                      onTap: _tryBiometrics,
                    ),
                    _PinKey(label: '0', onTap: () => _tapDigit('0')),
                    _PinKey(label: '⌫', onTap: _backspace, fontSize: 22),
                  ],
                ),
              ),
              // Cancel — dismiss and keep the child in Kid Mode
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinKey extends StatefulWidget {
  const _PinKey({required this.onTap, this.label = '', this.icon, this.fontSize = 30});
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
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _pressed ? AppColours.subtle : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: widget.icon ??
              Text(widget.label,
                  style: TextStyle(fontSize: widget.fontSize, fontWeight: FontWeight.w400, color: AppColours.textDark)),
        ),
      ),
    );
  }
}
