// ═══════════════════════════════════════════════════════
// S20 · QUIZ RESULT SCREEN
// ═══════════════════════════════════════════════════════
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/kid_provider.dart';

const _lockIcon =
    'M6 10V8a6 6 0 1112 0v2M5 10h14a1 1 0 011 1v9a1 1 0 01-1 1H5a1 1 0 01-1-1v-9a1 1 0 011-1z';

class QuizResultScreen extends ConsumerStatefulWidget {
  const QuizResultScreen({super.key});
  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  bool _review = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(quizSessionNotifierProvider);
    final score = session.correctCount;
    final total = session.total == 0 ? 5 : session.total;
    final pct = (score / total * 100).round();
    final xp = session.xpEarned == 0 ? 40 : session.xpEarned;
    final stars = session.starsEarned == 0 ? 16 : session.starsEarned;
    final amazing = pct >= 80;

    return Scaffold(
      backgroundColor: AppColours.kidBackground,
      body: SafeArea(
        child: _review
            ? _ReviewBody(
                session: session,
                total: total,
                onBack: () => setState(() => _review = false),
              )
            : _ResultBody(
                score: score,
                total: total,
                xp: xp,
                stars: stars,
                amazing: amazing,
                subject: session.subject,
                answerHistory: session.answerHistory,
                onReview: () => setState(() => _review = true),
                onTryAgain: () {
                  ref.read(quizSessionNotifierProvider.notifier).reset();
                  context.go(AppRoutes.quiz);
                },
                onHome: () {
                  ref.read(quizSessionNotifierProvider.notifier).reset();
                  context.go(AppRoutes.kid);
                },
              ),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.score,
    required this.total,
    required this.xp,
    required this.stars,
    required this.amazing,
    required this.subject,
    required this.answerHistory,
    required this.onReview,
    required this.onTryAgain,
    required this.onHome,
  });
  final int score, total, xp, stars;
  final bool amazing;
  final String subject;
  final List<bool> answerHistory;
  final VoidCallback onReview, onTryAgain, onHome;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti
        if (amazing) ..._confetti(),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Text(amazing ? '🏆' : '💪', style: const TextStyle(fontSize: 80)),
              ).animate().scale(begin: const Offset(.4, .4), duration: 600.ms, curve: Curves.elasticOut),
              Text(amazing ? 'Amazing! 🎉' : 'Good try! 💪',
                      style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: AppColours.kidInk))
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: .2, end: 0),
              const SizedBox(height: 4),
              Text('⚡ Quiz · ${subject.isEmpty ? "Fractions" : subject}',
                      style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.kidMuted))
                  .animate(delay: 250.ms)
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 20),
              // Score card (green)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColours.kidGreen, AppColours.kidGreenDark],
                  ),
                  boxShadow: [BoxShadow(color: AppColours.kidGreen.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    Text('YOUR SCORE',
                        style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.85), letterSpacing: 0.6)),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: Colors.white),
                        children: [
                          TextSpan(text: '$score', style: const TextStyle(fontSize: 58)),
                          TextSpan(text: ' / $total', style: TextStyle(fontSize: 28, color: Colors.white.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(total, (i) {
                        final correct = i < answerHistory.length ? answerHistory[i] : i < score;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Text(correct ? '✅' : '❌', style: const TextStyle(fontSize: 22)),
                        );
                      }),
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn(duration: 300.ms).slideY(begin: .1, end: 0),
              const SizedBox(height: 12),
              Row(
                children: [
                  _EarnedTile('⭐ +$stars', 'Stars', AppColours.kidYellow),
                  const SizedBox(width: 10),
                  _EarnedTile('⚡ +$xp', 'XP earned', AppColours.kidPurple),
                ],
              ).animate(delay: 380.ms).fadeIn(duration: 300.ms),
              const SizedBox(height: 12),
              if (score < total)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColours.line),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.nunito(fontSize: 13, color: AppColours.kidMuted, height: 1.6),
                      children: [
                        TextSpan(
                            text: 'You got ${total - score} wrong 💪\n',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColours.kidInk)),
                        const TextSpan(
                            text: 'Tap below to review the answers — understanding these helps you nail similar questions next time.'),
                      ],
                    ),
                  ),
                ).animate(delay: 420.ms).fadeIn(duration: 300.ms),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onReview,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColours.line)),
                  child: Center(
                    child: Text('📖 See All Answers + Explanations',
                        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.kidInk)),
                  ),
                ),
              ).animate(delay: 460.ms).fadeIn(duration: 300.ms),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onTryAgain,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColours.line)),
                        child: Center(
                          child: Text('Try Again',
                              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColours.kidInk)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Kid3dButton(
                      label: '🏠 Home',
                      onPressed: onHome,
                      colour: AppColours.kidBlue,
                      darkColour: AppColours.kidBlueDark,
                      fontSize: 15,
                    ),
                  ),
                ],
              ).animate(delay: 500.ms).fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _confetti() {
    const colours = [AppColours.kidBlue, AppColours.kidPurple, AppColours.kidYellow, AppColours.kidPink, AppColours.kidGreen];
    final rnd = math.Random(7);
    return List.generate(18, (i) {
      return Positioned(
        left: rnd.nextDouble() * 340,
        top: rnd.nextDouble() * 260,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: colours[i % colours.length], borderRadius: BorderRadius.circular(2)),
        ).animate(onPlay: (c) => c.repeat()).moveY(begin: -10, end: 20, duration: (1200 + i * 60).ms).fadeIn(),
      );
    });
  }
}

class _ReviewBody extends StatelessWidget {
  const _ReviewBody({required this.session, required this.total, required this.onBack});
  final QuizSessionState session;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final questions = session.questions;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 20, 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColours.line)),
                  child: const Center(child: Icon(Icons.arrow_back, size: 20, color: AppColours.kidInk)),
                ),
              ),
              const SizedBox(width: 12),
              Text('Review Answers',
                  style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            itemCount: questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final q = questions[i];
              final correct = i < session.answerHistory.length ? session.answerHistory[i] : false;
              final correctText = (q.correctIndex >= 0 && q.correctIndex < q.options.length) ? q.options[q.correctIndex] : '';
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: correct ? AppColours.kidGreen : AppColours.kidPink, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(color: correct ? AppColours.kidGreen : AppColours.kidPink, shape: BoxShape.circle),
                          child: Center(
                            child: Text('${i + 1}', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(q.questionText,
                              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: AppColours.kidInk, height: 1.3)),
                        ),
                        Text(correct ? '✅' : '❌', style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppColours.kidGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                      child: Text('Correct: $correctText',
                          style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.kidGreenDark)),
                    ),
                    if (q.explanation.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(q.explanation,
                          style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.kidMuted, height: 1.5)),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Kid3dButton(
            label: '← Back to Results',
            onPressed: onBack,
            colour: AppColours.kidPurple,
            darkColour: AppColours.kidPurpleDark,
          ),
        ),
      ],
    );
  }
}

class _EarnedTile extends StatelessWidget {
  const _EarnedTile(this.value, this.label, this.colour);
  final String value, label;
  final Color colour;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColours.line)),
          child: Column(
            children: [
              Text(value, style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: colour)),
              const SizedBox(height: 3),
              Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.kidMuted)),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════
// S21 · REWARDS & BADGES SCREEN
// ═══════════════════════════════════════════════════════

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  static const _badges = [
    _Badge('🥇', 'Maths Starter', true, true),
    _Badge('⭐', 'Spelling Star', true, false),
    _Badge('🃏', 'Flashcard Hero', true, false),
    _Badge('🔬', 'Science Explorer', false, false),
    _Badge('🏆', 'Quiz Champion', false, false),
    _Badge('🔥', '7-Day Learner', false, false),
    _Badge('✏️', 'Practice Pro', false, false),
    _Badge('🚀', 'Super Learner', false, false),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(activeChildProvider);
    final child = childAsync.valueOrNull;
    final earnedCount = _badges.where((b) => b.earned).length;

    return Scaffold(
      backgroundColor: AppColours.kidBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.kid),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColours.line)),
                      child: const Center(child: Icon(Icons.arrow_back, size: 20, color: AppColours.kidInk)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('My Rewards',
                      style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stars panel (yellow→pink gradient)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColours.kidYellow, AppColours.kidPink],
                        ),
                        boxShadow: [BoxShadow(color: AppColours.kidPink.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 44)),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${child?.stars ?? 240}',
                                      style: GoogleFonts.nunito(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white)),
                                  Text('Total Stars',
                                      style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.9))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _MiniStat('⚡', '${child?.xp ?? 340} XP'),
                              const SizedBox(width: 20),
                              _MiniStat('🔥', '${child?.streak ?? 4} streak'),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: .05, end: 0),
                    const SizedBox(height: 14),
                    // Science Explorer progress
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColours.line)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('🔬 Science Explorer',
                                    style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                                const SizedBox(height: 2),
                                Text('2 more quizzes to unlock!',
                                    style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.kidMuted)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('3/5',
                                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: AppColours.kidBlue)),
                              const SizedBox(height: 5),
                              Container(
                                width: 44,
                                height: 6,
                                decoration: BoxDecoration(color: AppColours.line, borderRadius: BorderRadius.circular(999)),
                                child: FractionallySizedBox(
                                  widthFactor: .6,
                                  alignment: Alignment.centerLeft,
                                  child: Container(decoration: BoxDecoration(color: AppColours.kidBlue, borderRadius: BorderRadius.circular(999))),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
                    const SizedBox(height: 16),
                    Text('BADGES · $earnedCount of ${_badges.length}',
                        style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900, color: AppColours.kidMuted, letterSpacing: 0.8)),
                    const SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                      children: _badges
                          .asMap()
                          .entries
                          .map((e) => _BadgeCard(badge: e.value)
                              .animate(delay: Duration(milliseconds: 100 + e.key * 40))
                              .fadeIn(duration: 250.ms)
                              .scale(begin: const Offset(.85, .85)))
                          .toList(),
                    ),
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

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.emoji, this.label);
  final String emoji, label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      );
}

class _Badge {
  const _Badge(this.emoji, this.label, this.earned, this.isNew);
  final String emoji, label;
  final bool earned, isNew;
}

const _greyscaleBadge = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final _Badge badge;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: badge.earned ? 1 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: badge.earned
                ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFFBEB), Colors.white])
                : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: badge.earned ? AppColours.kidYellow : AppColours.line, width: badge.earned ? 2 : 1.5),
            boxShadow: badge.earned ? [BoxShadow(color: AppColours.kidYellow.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))] : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    badge.earned
                        ? Text(badge.emoji, style: const TextStyle(fontSize: 30))
                        : ColorFiltered(colorFilter: _greyscaleBadge, child: Text(badge.emoji, style: const TextStyle(fontSize: 30))),
                    const SizedBox(height: 6),
                    Text(badge.label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            fontSize: 11, fontWeight: FontWeight.w800, color: badge.earned ? AppColours.kidInk : AppColours.kidMuted)),
                    if (!badge.earned) ...[
                      const SizedBox(height: 4),
                      appSvg(_lockIcon, size: 14, stroke: AppColours.kidMuted, strokeWidth: 2),
                    ],
                  ],
                ),
              ),
              if (badge.isNew)
                Positioned(
                  top: -8,
                  right: -6,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColours.kidPink, borderRadius: BorderRadius.circular(999)),
                      child: Text('NEW',
                          style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}
