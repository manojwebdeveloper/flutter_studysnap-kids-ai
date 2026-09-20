import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/kid_provider.dart';

const _kbBg = Color(0xFFDDE3EC);
const _keyShadow = Color(0xFFB6BFCC);

const _greyscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);

/// Words suitable for the letter-box spelling UI: a single alphabetic token,
/// short enough to fit on screen.
final _wordPattern = RegExp(r'^[A-Za-z]{2,12}$');

/// "Spell It" — a real spelling practice game built from the child's actual
/// flashcards (word = answer, clue = question). Shows a friendly empty state
/// when there's no real content to practise with yet.
class TypeAnswerScreen extends ConsumerStatefulWidget {
  const TypeAnswerScreen({super.key});
  @override
  ConsumerState<TypeAnswerScreen> createState() => _TypeAnswerScreenState();
}

class _TypeAnswerScreenState extends ConsumerState<TypeAnswerScreen>
    with SingleTickerProviderStateMixin {
  String _typed = '';
  bool? _correct;
  int _index = 0;
  int _wrongAttempts = 0;
  late AnimationController _cursor;

  static const _rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

  @override
  void initState() {
    super.initState();
    _cursor = AnimationController(vsync: this, duration: const Duration(milliseconds: 550))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursor.dispose();
    super.dispose();
  }

  List<PracticeCard> _qualifying(List<PracticeCard> all) =>
      all.where((c) => _wordPattern.hasMatch(c.card.answer.trim())).toList();

  void _tapKey(String letter, int targetLength) {
    if (_typed.length >= targetLength) return;
    HapticFeedback.lightImpact();
    setState(() {
      _typed += letter;
      _correct = null;
    });
  }

  void _backspace() {
    if (_typed.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _typed = _typed.substring(0, _typed.length - 1);
      _correct = null;
    });
  }

  void _check(String target, int total) {
    HapticFeedback.mediumImpact();
    final ok = _typed == target;
    setState(() {
      _correct = ok;
      if (!ok) _wrongAttempts++;
    });
    if (ok) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        if (_index + 1 >= total) {
          context.go(AppRoutes.learningPath);
        } else {
          setState(() {
            _index++;
            _typed = '';
            _correct = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(practiceFlashcardsProvider);
    final words = _qualifying(cardsAsync.valueOrNull ?? const <PracticeCard>[]);

    if (cardsAsync.isLoading && words.isEmpty) {
      return Scaffold(
        backgroundColor: AppColours.kidBackground,
        body: SafeArea(
          child: Column(
            children: [
              _header('SPELLING'),
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppColours.kidBlue))),
            ],
          ),
        ),
      );
    }

    if (words.isEmpty) {
      return Scaffold(
        backgroundColor: AppColours.kidBackground,
        body: SafeArea(
          child: Column(
            children: [
              _header('SPELLING'),
              const Expanded(
                child: KidEmptyState(
                  emoji: '✏️',
                  title: 'No words to spell yet',
                  message: 'Ask a grown-up to scan a worksheet — spelling words will appear here!',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final current = words[_index.clamp(0, words.length - 1)];
    final target = current.card.answer.trim().toUpperCase();
    final livesLeft = (5 - _wrongAttempts).clamp(0, 5);

    return Scaffold(
      backgroundColor: AppColours.kidBackground,
      body: SafeArea(
        child: Column(
          children: [
            _header(current.subject.toUpperCase(), livesLeft: livesLeft),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _progressBar((_index + 1) / words.length),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  children: [
                    _promptCard(current.card.question, _index, words.length),
                    const SizedBox(height: 16),
                    _letterBoxes(target),
                    const SizedBox(height: 12),
                    _hintChip(target),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            _keyboard(target, words.length),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────
  Widget _header(String subtitle, {int livesLeft = 5}) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 20, 6),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.go(AppRoutes.learningPath),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: const Center(child: Icon(Icons.close, size: 20, color: AppColours.kidInk)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subtitle,
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AppColours.kidMuted, letterSpacing: 0.4)),
                  Text('Spell It', style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                ],
              ),
            ),
            Row(
              children: List.generate(5, (i) {
                const heart = Text('❤️', style: TextStyle(fontSize: 18));
                return Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: i < livesLeft ? heart : const Opacity(opacity: 0.35, child: ColorFiltered(colorFilter: _greyscale, child: heart)),
                );
              }),
            ),
          ],
        ),
      );

  // ── Progress bar ───────────────────────────────────────
  Widget _progressBar(double value) => ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 2)],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColours.kidYellow, AppColours.kidGreen]),
              ),
            ),
          ),
        ),
      );

  // ── Prompt card ────────────────────────────────────────
  Widget _promptCard(String clue, int index, int total) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColours.kidYellow.withOpacity(0.44), width: 3),
          boxShadow: [BoxShadow(color: AppColours.kidYellow.withOpacity(0.22), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _pill('WORD ${index + 1} OF $total', AppColours.kidYellow, const Color(0xFF78350F)),
            const SizedBox(height: 14),
            Text('Type the word that means:',
                style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
            const SizedBox(height: 8),
            Text(
              clue,
              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.kidMuted, height: 1.5),
            ),
          ],
        ),
      );

  // ── Letter boxes ───────────────────────────────────────
  Widget _letterBoxes(String target) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(target.length, (i) {
          final filled = i < _typed.length;
          final isCurrent = i == _typed.length;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.5),
            child: filled
                ? Container(
                    width: 42,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColours.kidGreen, width: 2.5),
                      boxShadow: [BoxShadow(color: AppColours.kidGreen.withOpacity(0.33), offset: const Offset(0, 3))],
                    ),
                    child: Text(_typed[i], style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                  )
                : isCurrent
                    ? Container(
                        width: 42,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColours.kidBlue, width: 2.5),
                          boxShadow: [BoxShadow(color: AppColours.kidBlue.withOpacity(0.18), blurRadius: 0, spreadRadius: 4)],
                        ),
                        child: FadeTransition(
                          opacity: _cursor,
                          child: Container(width: 2, height: 26, color: AppColours.kidBlue),
                        ),
                      )
                    : CustomPaint(
                        size: const Size(42, 52),
                        painter: _DashedBoxPainter(),
                      ),
          );
        }),
      );

  // ── Hint chip ──────────────────────────────────────────
  Widget _hintChip(String target) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(color: AppColours.kidPurple.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💡', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                _correct == false
                    ? 'Not quite — try again!'
                    : 'Starts with ${target[0]} and ends with ${target[target.length - 1]}',
                style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: AppColours.kidPurpleDark),
              ),
            ],
          ),
        ),
      );

  // ── Keyboard ───────────────────────────────────────────
  Widget _keyboard(String target, int total) => Container(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
        decoration: const BoxDecoration(
          color: _kbBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          children: [
            for (int r = 0; r < _rows.length; r++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (r == 2) _wideKey(child: const Icon(Icons.keyboard_arrow_up, size: 20, color: AppColours.kidInk), onTap: () {}),
                  ..._rows[r].split('').map((c) => _letterKey(c, target.length)),
                  if (r == 2) _wideKey(child: const Icon(Icons.backspace_outlined, size: 18, color: AppColours.kidInk), onTap: _backspace),
                ],
              ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _keyBase(width: 200, child: Text('space', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.kidMuted)), onTap: () {}),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _check(target, total),
                  child: Container(
                    width: 80,
                    height: 40,
                    margin: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      color: AppColours.kidYellow,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [BoxShadow(color: AppColours.kidYellow.withOpacity(0.6), offset: const Offset(0, 2))],
                    ),
                    child: Center(
                      child: Text('Check', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _letterKey(String c, int targetLength) => _keyBase(
        minWidth: 30,
        child: Text(c, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.kidInk)),
        onTap: () => _tapKey(c, targetLength),
      );

  Widget _wideKey({required Widget child, required VoidCallback onTap}) =>
      _keyBase(width: 40, child: child, onTap: onTap);

  Widget _keyBase({double? width, double minWidth = 30, required Widget child, required VoidCallback onTap}) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          constraints: BoxConstraints(minWidth: minWidth),
          height: 40,
          margin: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            boxShadow: const [BoxShadow(color: _keyShadow, offset: Offset(0, 1.5))],
          ),
          child: Center(child: child),
        ),
      );

  Widget _pill(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: fg, letterSpacing: 0.4)),
      );
}

class _DashedBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColours.kidMuted.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(12),
    );
    final path = Path()..addRRect(rrect);
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + dash), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
