import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/onboarding_provider.dart';

class ParentPinScreen extends ConsumerStatefulWidget {
  const ParentPinScreen({super.key});
  @override
  ConsumerState<ParentPinScreen> createState() => _ParentPinScreenState();
}

class _ParentPinScreenState extends ConsumerState<ParentPinScreen> {
  String _firstPin = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(parentPinNotifierProvider.notifier).reset();
    });
  }

  Future<void> _onDigit(String digit) async {
    final notifier = ref.read(parentPinNotifierProvider.notifier);
    // Append the digit exactly once…
    notifier.tapDigit(digit);

    // …then read the resulting PIN back from the notifier (do NOT append again).
    final pin = ref.read(parentPinNotifierProvider).pin;
    if (pin.length == 4) {
      // Brief pause so the fourth dot is visibly filled before the step advances.
      await Future.delayed(const Duration(milliseconds: 120));
      if (!ref.read(parentPinNotifierProvider).isConfirming) {
        _firstPin = pin;
      }
      final done = await notifier.onPinComplete(_firstPin);
      if (done && mounted) context.go(AppRoutes.addChild);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parentPinNotifierProvider);
    final err = state.hasError;
    final dotColour = err ? AppColours.red : AppColours.blue;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: NavBackIconButton(
                  onPressed: () => context.go(AppRoutes.onboarding),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColours.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: appSvg(
                    'M6 10V8a6 6 0 1112 0v2M5 10h14a1 1 0 011 1v9a1 1 0 01-1 1H5a1 1 0 01-1-1v-9a1 1 0 011-1z',
                    size: 26,
                    stroke: AppColours.blue,
                    strokeWidth: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                state.isConfirming ? 'Confirm Your PIN' : 'Create Parent PIN',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColours.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.isConfirming
                    ? 'Enter the same PIN again to confirm.'
                    : 'Parent Mode controls scanning, settings and progress. Keep it protected from little hands.',
                style: const TextStyle(fontSize: 15, color: AppColours.muted, height: 1.5),
              ),
              const SizedBox(height: 20),
              // PIN dots
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < state.pin.length;
                    final isCurrent = i == state.pin.length && state.pin.length < 4;
                    return Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 9),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? dotColour : Colors.transparent,
                        border: Border.all(color: dotColour, width: 2),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: dotColour.withOpacity(0.22),
                                  blurRadius: 0,
                                  spreadRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  err
                      ? "PINs don't match — try again"
                      : state.isConfirming
                          ? 'Step 2 of 2 · Confirm your PIN'
                          : 'Step 1 of 2 · Enter a 4-digit PIN',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: err ? AppColours.red : AppColours.muted,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Number pad
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                children: [
                  ...['1', '2', '3', '4', '5', '6', '7', '8', '9']
                      .map((d) => _Key(d, () => _onDigit(d))),
                  const SizedBox(),
                  _Key('0', () => _onDigit('0')),
                  _Key(
                    '',
                    () => ref.read(parentPinNotifierProvider.notifier).backspace(),
                    child: appSvg(
                      'M9 4h17a2 2 0 012 2v8a2 2 0 01-2 2H9L2 10l7-6zM14 8l6 4M20 8l-6 4',
                      size: 24,
                      stroke: AppColours.muted,
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _Key extends StatefulWidget {
  const _Key(this.label, this.onTap, {this.child});
  final String label;
  final VoidCallback onTap;
  final Widget? child;
  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          setState(() => _pressed = true);
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          decoration: BoxDecoration(
            color: _pressed ? AppColours.subtle : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: widget.child ??
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColours.ink,
                  ),
                ),
          ),
        ),
      );
}
