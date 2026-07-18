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
  @override
  ConsumerState<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends ConsumerState<FlashcardStudyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  bool _showFront = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _flipAnim = Tween<double>(begin: 0, end: math.pi)
        .animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load real flashcards for the child's first approved set. If none
      // exists the session stays empty and we show an empty state.
      final state = ref.read(flashcardSessionNotifierProvider);
      if (state.cards.isEmpty) {
        final sets = await ref.read(approvedSetsProvider.future);
        if (sets.isNotEmpty && mounted) {
          await ref.read(flashcardSessionNotifierProvider.notifier).loadSet(sets.first);
        }
      }
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

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
    final session = ref.watch(flashcardSessionNotifierProvider);
    final card = session.current;
    final subject = session.subject.isEmpty ? 'Maths' : session.subject;

    if (card == null) {
      return Scaffold(
        backgroundColor: AppColours.kidBackground,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 20, 0),
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.learningPath),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColours.line)),
                      child: const Center(child: Icon(Icons.close, size: 20, color: AppColours.kidInk)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _loaded
                    ? const KidEmptyState(
                        emoji: '🃏',
                        title: 'No flashcards yet',
                        message: 'Ask a grown-up to scan a worksheet — your flashcards will appear here!',
                      )
                    : const Center(child: CircularProgressIndicator(color: AppColours.kidBlue)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColours.kidBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 20, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.learningPath),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColours.line)),
                      child: const Center(child: Icon(Icons.close, size: 20, color: AppColours.kidInk)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColours.kidBlue.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                          child: Text(subject.toUpperCase(),
                              style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: AppColours.kidBlueDark, letterSpacing: 0.6)),
                        ),
                        const SizedBox(height: 2),
                        Text('Flashcards', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColours.kidYellow, borderRadius: BorderRadius.circular(999)),
                    child: Text('${session.currentIndex + 1} / ${session.total}',
                        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF78350F))),
                  ),
                ],
              ),
            ),
            // ── Progress bar (green→blue) ───────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 8,
                  color: const Color(0xFFE0F2FE),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: session.progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [AppColours.kidGreen, AppColours.kidBlue]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ── Card ────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: GestureDetector(
                  onTap: _showFront ? _flip : null,
                  child: AnimatedBuilder(
                    animation: _flipAnim,
                    builder: (_, __) {
                      final angle = _flipAnim.value;
                      final isFront = angle < math.pi / 2;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: isFront
                            ? _CardFront(text: card?.question ?? '')
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(math.pi),
                                child: _CardBack(answer: card?.answer ?? ''),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // ── Actions ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: _showFront
                  ? Kid3dButton(
                      label: '👀 Show Answer',
                      onPressed: _flip,
                      colour: AppColours.kidBlue,
                      darkColour: AppColours.kidBlueDark,
                    )
                  : Row(
                      children: [
                        Expanded(child: _RateBtn('🔄 Try Again', AppColours.kidPink, _flip)),
                        const SizedBox(width: 8),
                        Expanded(child: _RateBtn('🤔 Not Sure', AppColours.kidYellow, () => _rate(false))),
                        const SizedBox(width: 8),
                        Expanded(child: _RateBtn('😊 Got it', AppColours.kidGreen, () => _rate(true))),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColours.kidBlue, width: 2.5),
          boxShadow: [BoxShadow(color: AppColours.kidBlue.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: AppColours.kidBlue.withOpacity(0.12), shape: BoxShape.circle),
              child: const Center(child: Text('❓', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900, color: AppColours.kidInk, height: 1.25)),
            ),
            const SizedBox(height: 20),
            Text('Tap the card to flip',
                style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.kidMuted)),
          ],
        ),
      );
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.answer});
  final String answer;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColours.kidGreen, width: 2.5),
          boxShadow: [BoxShadow(color: AppColours.kidGreen.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _backBox(
                bg: AppColours.kidGreen.withOpacity(0.12),
                border: AppColours.kidGreen,
                label: 'ANSWER',
                labelColour: AppColours.kidGreenDark,
                body: answer,
                bodySize: 22,
              ),
              const SizedBox(height: 12),
              _backBox(
                bg: const Color(0xFFEDE9FE),
                border: AppColours.kidPurple,
                label: '💡 MEMORY TIP',
                labelColour: AppColours.kidPurpleDark,
                body: 'Say the answer out loud, then cover it and try again. Repeating it helps it stick!',
                bodySize: 14,
              ),
            ],
          ),
        ),
      );

  Widget _backBox({
    required Color bg,
    required Color border,
    required String label,
    required Color labelColour,
    required String body,
    required double bodySize,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900, color: labelColour, letterSpacing: 0.6)),
            const SizedBox(height: 6),
            Text(body,
                style: GoogleFonts.nunito(fontSize: bodySize, fontWeight: FontWeight.w800, color: AppColours.kidInk, height: 1.4)),
          ],
        ),
      );
}

class _RateBtn extends StatefulWidget {
  const _RateBtn(this.label, this.colour, this.onTap);
  final String label;
  final Color colour;
  final VoidCallback onTap;
  @override
  State<_RateBtn> createState() => _RateBtnState();
}

class _RateBtnState extends State<_RateBtn> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? .95 : 1,
          duration: const Duration(milliseconds: 80),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.colour, width: 2),
            ),
            child: Center(
              child: Text(widget.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: widget.colour)),
            ),
          ),
        ),
      );
}
