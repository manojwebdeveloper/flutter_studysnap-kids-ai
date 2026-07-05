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
    notifier.tapDigit(digit);

    final pin = ref.read(parentPinNotifierProvider).pin + digit; // peek at new value
    if (pin.length == 4) {
      await Future.delayed(const Duration(milliseconds: 250));
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

    return Scaffold(
      backgroundColor: AppColours.bg,
      appBar: AppBar(
        backgroundColor: AppColours.bg,
        leading: NavBackIconButton(
          onPressed: () => context.go(AppRoutes.onboarding),
        ),
      ),
      body: SafeArea(
        child: ResponsiveBody(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 8),
            Container(width: 52, height: 52,
              decoration: BoxDecoration(color: AppColours.blueLight, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('🔒', style: TextStyle(fontSize: 26)))),
            const SizedBox(height: 18),
            Text(state.isConfirming ? 'Confirm Your PIN' : 'Create Parent PIN',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColours.textDark, letterSpacing: -.3)),
            const SizedBox(height: 8),
            Text(
              state.isConfirming
                  ? 'Enter the same PIN again to confirm.'
                  : 'Parent Mode controls scanning, settings and progress. Keep it protected from little hands.',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.textMuted, height: 1.55)),
            const SizedBox(height: 32),
            // PIN dots
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 9),
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < state.pin.length
                      ? (state.hasError ? AppColours.red : AppColours.blue)
                      : Colors.transparent,
                  border: Border.all(
                    color: state.hasError ? AppColours.red : AppColours.blue, width: 2),
                ),
              ))),
            const SizedBox(height: 10),
            Center(child: Text(
              state.hasError
                  ? "PINs don't match — try again"
                  : state.isConfirming
                      ? 'Step 2 of 2 · Confirm your PIN'
                      : 'Step 1 of 2 · Enter a 4-digit PIN',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: state.hasError ? AppColours.red : AppColours.textMuted))),
            const SizedBox(height: 28),
            // Number pad
            Expanded(child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.4,
              children: [
                ...['1','2','3','4','5','6','7','8','9'].map((d) => _Key(d, () => _onDigit(d))),
                const SizedBox(),
                _Key('0', () => _onDigit('0')),
                _Key('⌫', () => ref.read(parentPinNotifierProvider.notifier).backspace(),
                  fontSize: 22),
              ],
            )),
          ]),
        )),
      ),
    );
  }
}

class _Key extends StatefulWidget {
  const _Key(this.label, this.onTap, {this.fontSize = 30});
  final String label;
  final VoidCallback onTap;
  final double fontSize;
  @override State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) { HapticFeedback.lightImpact(); setState(() => _pressed = true); },
    onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _pressed ? AppColours.subtle : Colors.transparent,
        borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(widget.label,
        style: TextStyle(fontSize: widget.fontSize, fontWeight: FontWeight.w500, color: AppColours.textDark))),
    ),
  );
}
