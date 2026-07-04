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

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});
  @override ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    // Start a default quiz session if none loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = ref.read(quizSessionNotifierProvider);
      if (state.questions.isEmpty) {
        // Load a default sample session
        await ref.read(quizSessionNotifierProvider.notifier).loadSet(
          _dummySet(),
          durationSeconds: 180,
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
    final session  = ref.watch(quizSessionNotifierProvider);
    final notifier = ref.read(quizSessionNotifierProvider.notifier);
    final question = session.current;

    // Navigate to result when complete
    ref.listen(quizSessionNotifierProvider, (_, next) {
      if (next.isComplete && mounted) context.go(AppRoutes.quizResult);
    });

    if (question == null) {
      return const Scaffold(backgroundColor: AppColours.kidBg,
        body: Center(child: CircularProgressIndicator(color: AppColours.kidPurple)));
    }

    return Scaffold(
      backgroundColor: AppColours.kidBg,
      body: SafeArea(child: Column(children: [
        // Top bar
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 20, 10),
          child: Row(children: [
            GestureDetector(onTap: () { notifier.reset(); context.go(AppRoutes.kid); },
              child: const Icon(Icons.close, size: 26, color: AppColours.textDark)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('⚡ ${session.total}-QUESTION QUIZ',
                style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900, color: AppColours.textMuted)),
              Text('Question ${session.currentIndex + 1} of ${session.total}',
                style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: AppColours.textDark)),
            ])),
            // Timer
            Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(99)),
              child: Row(children: [
                const Text('⏱', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(session.timerDisplay, style: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.textMuted)),
              ])),
          ])),

        // Progress bar
        LinearProgressIndicator(
          value: session.progress,
          backgroundColor: const Color(0xFFE0F2FE),
          valueColor: const AlwaysStoppedAnimation(AppColours.kidPurple),
          minHeight: 6,
        ),

        // Question + Options
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PICK THE CORRECT ANSWER',
              style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900,
                color: AppColours.textMuted, letterSpacing: .5)),
            const SizedBox(height: 8),
            Text(question.questionText,
              style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w900,
                color: AppColours.textDark, height: 1.3))
                .animate().fadeIn(duration: 200.ms).slideY(begin: .05, end: 0),
            const SizedBox(height: 20),

            // Answer grid
            _OptionsGrid(session: session, notifier: notifier),

            // Feedback card
            if (session.answered) ...[
              const SizedBox(height: 14),
              _FeedbackCard(
                isCorrect: session.isCorrect ?? false,
                explanation: question.explanation,
              ).animate().fadeIn(duration: 250.ms).slideY(begin: .1, end: 0),
            ],
            const SizedBox(height: 20),
          ]),
        )),

        // Next button
        if (session.answered)
          Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Kid3dButton(
              label: session.isLastQuestion ? '🏆 See Results' : 'Next →',
              onPressed: () => notifier.next(),
              colour: AppColours.kidPurple,
              darkColour: AppColours.kidPurpleDark,
            ).animate().fadeIn(duration: 200.ms).slideY(begin: .1, end: 0)),
      ])),
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
        ? Column(children: question.options.asMap().entries.map((e) =>
            _OptionBtn(index: e.key, label: e.value, session: session, notifier: notifier,
              isWide: true)).toList())
        : GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 10, mainAxisSpacing: 10,
            children: question.options.asMap().entries.map((e) =>
                _OptionBtn(index: e.key, label: e.value, session: session, notifier: notifier)).toList());
  }
}

class _OptionBtn extends StatefulWidget {
  const _OptionBtn({required this.index, required this.label, required this.session,
    required this.notifier, this.isWide = false});
  final int index;
  final String label;
  final QuizSessionState session;
  final QuizSessionNotifier notifier;
  final bool isWide;

  @override State<_OptionBtn> createState() => _OptionBtnState();
}

class _OptionBtnState extends State<_OptionBtn> {
  bool _pressed = false;

  Color get _bg {
    if (!widget.session.answered) return Colors.white;
    if (widget.index == widget.session.current!.correctIndex) return AppColours.greenLight;
    if (widget.index == widget.session.selectedIndex) return AppColours.redLight;
    return Colors.white;
  }

  Color get _border {
    if (!widget.session.answered) return AppColours.line;
    if (widget.index == widget.session.current!.correctIndex) return AppColours.kidGreen;
    if (widget.index == widget.session.selectedIndex) return AppColours.kidPink;
    return AppColours.line;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) { if (!widget.session.answered) setState(() => _pressed = true); },
    onTapUp: (_) {
      setState(() => _pressed = false);
      if (!widget.session.answered) {
        HapticFeedback.lightImpact();
        widget.notifier.answer(widget.index);
      }
    },
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedScale(scale: _pressed ? .96 : 1, duration: const Duration(milliseconds: 80),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        margin: widget.isWide ? const EdgeInsets.only(bottom: 10) : EdgeInsets.zero,
        padding: EdgeInsets.symmetric(vertical: widget.isWide ? 18 : 20, horizontal: 12),
        decoration: BoxDecoration(
          color: _bg, borderRadius: BorderRadius.circular(17),
          border: Border.all(color: _border, width: 2)),
        child: Center(child: Text(widget.label,
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: AppColours.textDark))))),
  );
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.isCorrect, required this.explanation});
  final bool isCorrect;
  final String explanation;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: isCorrect ? AppColours.greenLight : AppColours.redLight,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: isCorrect ? AppColours.kidGreen : AppColours.kidPink, width: 1.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(isCorrect ? '🎉 Correct! Nice one!' : 'Not quite — keep going! 💪',
        style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900,
          color: isCorrect ? AppColours.green : AppColours.red)),
      const SizedBox(height: 4),
      Text(explanation, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700,
        color: AppColours.textMuted, height: 1.55)),
    ]),
  );
}



