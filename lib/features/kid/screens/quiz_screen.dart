import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../domain/entities/study_set_entity.dart';
import '../providers/kid_provider.dart';

const _quizDuration = 180;

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});
  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = ref.read(quizSessionNotifierProvider);
      if (state.questions.isEmpty) {
        await ref.read(quizSessionNotifierProvider.notifier).loadSet(
              _dummySet(),
              durationSeconds: _quizDuration,
            );
      }
    });
  }

  StudySetEntity _dummySet() {
    return StudySetEntity(
      id: 'demo-set',
      childId: '',
      title: 'Fractions',
      subject: 'Maths',
      yearGroup: 'Year 4',
      source: 'scanned',
      status: 'approved',
      isApproved: true,
      cardCount: 5,
      questionCount: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(quizSessionNotifierProvider);
    final notifier = ref.read(quizSessionNotifierProvider.notifier);
    final question = session.current;
    final subject = session.subject.isEmpty ? 'Maths' : session.subject;

    ref.listen(quizSessionNotifierProvider, (_, next) {
      if (next.isComplete && mounted) context.go(AppRoutes.quizResult);
    });

    if (question == null) {
      return const Scaffold(
        backgroundColor: AppColours.kidBackground,
        body: Center(child: CircularProgressIndicator(color: AppColours.kidPurple)),
      );
    }

    final timerFactor = (session.secondsRemaining / _quizDuration).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColours.kidBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (white, bottom border) ──────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColours.line)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      notifier.reset();
                      context.go(AppRoutes.kid);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: AppColours.kidBackground, borderRadius: BorderRadius.circular(12)),
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
                          decoration: BoxDecoration(color: AppColours.kidPurple.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                          child: Text('$subject · QUIZ',
                              style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: AppColours.kidPurpleDark, letterSpacing: 0.5)),
                        ),
                        const SizedBox(height: 2),
                        Text('Question ${session.currentIndex + 1} of ${session.total}',
                            style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColours.kidPink.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      children: [
                        const Text('⏱', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(session.timerDisplay,
                            style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: AppColours.kidPink)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── Timer bar (green→yellow→pink, shrinking) ───
            ClipRRect(
              child: Container(
                height: 5,
                color: const Color(0xFFF1F5F9),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: timerFactor,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppColours.kidGreen, AppColours.kidYellow, AppColours.kidPink]),
                    ),
                  ),
                ),
              ),
            ),
            // ── Content ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress dots
                    Row(
                      children: List.generate(session.total, (i) {
                        final done = i < session.currentIndex;
                        final active = i == session.currentIndex;
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: active ? 22 : 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: done
                                ? AppColours.kidGreen
                                : active
                                    ? AppColours.kidPurple
                                    : AppColours.line,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    // Question card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColours.kidPurple.withOpacity(0.33), width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PICK THE CORRECT ANSWER',
                              style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: AppColours.kidMuted, letterSpacing: 0.6)),
                          const SizedBox(height: 8),
                          Text(question.questionText,
                                  style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w900, color: AppColours.kidInk, height: 1.25))
                              .animate().fadeIn(duration: 200.ms).slideY(begin: .05, end: 0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _OptionsGrid(session: session, notifier: notifier),
                    if (session.answered) ...[
                      const SizedBox(height: 16),
                      _FeedbackCard(isCorrect: session.isCorrect ?? false, explanation: question.explanation)
                          .animate()
                          .fadeIn(duration: 250.ms)
                          .slideY(begin: .1, end: 0),
                      const SizedBox(height: 16),
                      Kid3dButton(
                        label: session.isLastQuestion ? '🏆 See Results' : 'Next →',
                        onPressed: () => notifier.next(),
                        colour: AppColours.kidPurple,
                        darkColour: AppColours.kidPurpleDark,
                      ).animate().fadeIn(duration: 200.ms).slideY(begin: .1, end: 0),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionsGrid extends StatelessWidget {
  const _OptionsGrid({required this.session, required this.notifier});
  final QuizSessionState session;
  final QuizSessionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final question = session.current!;
    final isTrueFalse = question.type == 'true_false';

    return isTrueFalse
        ? Column(
            children: question.options
                .asMap()
                .entries
                .map((e) => _OptionBtn(index: e.key, label: e.value, session: session, notifier: notifier, isWide: true))
                .toList())
        : GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: question.options
                .asMap()
                .entries
                .map((e) => _OptionBtn(index: e.key, label: e.value, session: session, notifier: notifier))
                .toList());
  }
}

class _OptionBtn extends StatefulWidget {
  const _OptionBtn({required this.index, required this.label, required this.session, required this.notifier, this.isWide = false});
  final int index;
  final String label;
  final QuizSessionState session;
  final QuizSessionNotifier notifier;
  final bool isWide;

  @override
  State<_OptionBtn> createState() => _OptionBtnState();
}

class _OptionBtnState extends State<_OptionBtn> {
  bool _pressed = false;

  bool get _isCorrect => widget.index == widget.session.current!.correctIndex;
  bool get _isPickedWrong => widget.session.answered && widget.index == widget.session.selectedIndex && !_isCorrect;

  Color get _bg {
    if (!widget.session.answered) return Colors.white;
    if (_isCorrect) return AppColours.kidGreen;
    if (_isPickedWrong) return AppColours.kidPink.withOpacity(0.12);
    return Colors.white;
  }

  Color get _border {
    if (!widget.session.answered) return AppColours.line;
    if (_isCorrect) return AppColours.kidGreen;
    if (_isPickedWrong) return AppColours.kidPink;
    return AppColours.line;
  }

  Color get _textColour {
    if (widget.session.answered && _isCorrect) return Colors.white;
    return AppColours.kidInk;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) {
          if (!widget.session.answered) setState(() => _pressed = true);
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          if (!widget.session.answered) {
            HapticFeedback.lightImpact();
            widget.notifier.answer(widget.index);
          }
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? .96 : 1,
          duration: const Duration(milliseconds: 80),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: widget.isWide ? const EdgeInsets.only(bottom: 10) : EdgeInsets.zero,
            padding: EdgeInsets.symmetric(vertical: widget.isWide ? 18 : 16, horizontal: 12),
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border, width: 2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(widget.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(fontSize: 34, fontWeight: FontWeight.w900, color: _textColour)),
                ),
                if (widget.session.answered && _isCorrect) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Center(child: Icon(Icons.check, size: 16, color: AppColours.kidGreen)),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.isCorrect, required this.explanation});
  final bool isCorrect;
  final String explanation;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCorrect ? AppColours.kidGreen.withOpacity(0.12) : AppColours.kidPink.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isCorrect ? AppColours.kidGreen : AppColours.kidPink, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isCorrect ? '🎉 Correct! Nice one!' : 'Not quite — keep going! 💪',
                style: GoogleFonts.nunito(
                    fontSize: 15, fontWeight: FontWeight.w900, color: isCorrect ? AppColours.kidGreenDark : AppColours.kidPink)),
            if (explanation.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(explanation,
                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.kidMuted, height: 1.5)),
            ],
          ],
        ),
      );
}
