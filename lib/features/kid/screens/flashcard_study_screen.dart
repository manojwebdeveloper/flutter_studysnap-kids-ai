import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/kid_provider.dart';

class FlashcardStudyScreen extends ConsumerStatefulWidget {
  const FlashcardStudyScreen({super.key});
  @override ConsumerState<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends ConsumerState<FlashcardStudyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _flipAnim = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() { _flipCtrl.dispose(); super.dispose(); }

  void _flip() {
    HapticFeedback.lightImpact();
    if (_showFront) {
      _flipCtrl.forward();
    } else {
      _flipCtrl.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  Future<void> _rate(bool knew) async {
    HapticFeedback.mediumImpact();
    // Reset flip state for next card
    _flipCtrl.reset();
    setState(() => _showFront = true);
    await ref.read(flashcardSessionNotifierProvider.notifier).rate(knew);
    final state = ref.read(flashcardSessionNotifierProvider);
    if (state.isComplete && mounted) {
      context.go(AppRoutes.quizResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session  = ref.watch(flashcardSessionNotifierProvider);
    final card     = session.current;

    return Scaffold(
      backgroundColor: AppColours.kidBg,
      body: SafeArea(child: Column(children: [
        // Top bar
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 20, 10),
          child: Row(children: [
            GestureDetector(onTap: () => context.go(AppRoutes.learningPath),
              child: const Icon(Icons.close, size: 26, color: AppColours.textDark)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('MATHS · FRACTIONS', style: GoogleFonts.nunito(
                fontSize: 11, fontWeight: FontWeight.w900, color: AppColours.kidBlue, letterSpacing: .6)),
              Text('Flashcards', style: GoogleFonts.nunito(
                fontSize: 17, fontWeight: FontWeight.w900, color: AppColours.textDark)),
            ])),
            Text('${session.currentIndex + 1} / ${session.total}',
              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.textMuted)),
          ])),

        // Progress bar
        LinearProgressIndicator(
          value: session.progress,
          backgroundColor: const Color(0xFFE0F2FE),
          valueColor: const AlwaysStoppedAnimation(AppColours.kidBlue),
          minHeight: 5,
        ),

        // Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: GestureDetector(
              onTap: _showFront ? _flip : null,
              child: AnimatedBuilder(
                animation: _flipAnim,
                builder: (_, __) {
                  final angle  = _flipAnim.value;
                  final isFront = angle < math.pi / 2;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: isFront
                        ? _CardFace(isFront: true, text: card?.question ?? '', onTap: _flip)
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: _CardFace(isFront: false, text: card?.answer ?? '')),
                  );
                },
              ),
            ),
          ),
        ),

        // Actions
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: _showFront
              ? Kid3dButton(
                  label: '👀 Show Answer',
                  onPressed: _flip,
                  colour: AppColours.kidBlue,
                  darkColour: AppColours.kidBlueDark,
                )
              : Row(children: [
                  Expanded(child: _RateBtn('😕 Missed it', const Color(0xFFFEF2F2), AppColours.red, () => _rate(false))),
                  const SizedBox(width: 10),
                  Expanded(child: _RateBtn('😊 Got it!', AppColours.greenLight, AppColours.green, () => _rate(true))),
                ])),
      ])),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.isFront, required this.text, this.onTap});
  final bool isFront;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isFront ? AppColours.line : AppColours.kidBlue,
        width: isFront ? 1.5 : 2.5,
      ),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(isFront ? 'QUESTION' : 'ANSWER',
            style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900,
              color: isFront ? AppColours.textMuted : AppColours.kidBlue, letterSpacing: .5)),
          Text(isFront ? 'Tap to flip' : 'Tap to flip back',
            style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
        ])),
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(isFront ? '❓' : '✅', style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 14),
          Text(text, textAlign: TextAlign.center,
            style: isFront
                ? GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w900, color: AppColours.textDark, height: 1.3)
                : GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w700, color: AppColours.textInk, height: 1.6)),
        ])))),
    ]),
  );
}

class _RateBtn extends StatefulWidget {
  const _RateBtn(this.label, this.bg, this.colour, this.onTap);
  final String label;
  final Color bg, colour;
  final VoidCallback onTap;
  @override State<_RateBtn> createState() => _RateBtnState();
}

class _RateBtnState extends State<_RateBtn> {
  bool _pressed = false;
  @override Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _pressed = true),
    onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedScale(scale: _pressed ? .96 : 1, duration: const Duration(milliseconds: 80),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: widget.bg, borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text(widget.label, style: GoogleFonts.nunito(
          fontSize: 15, fontWeight: FontWeight.w900, color: widget.colour))))));
}
