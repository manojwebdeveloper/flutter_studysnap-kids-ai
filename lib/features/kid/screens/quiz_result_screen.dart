// ═══════════════════════════════════════════════════════
// S20 · QUIZ RESULT SCREEN
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/kid_provider.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(quizSessionNotifierProvider);
    final score   = session.correctCount;
    final total   = session.total == 0 ? 5 : session.total;
    final pct     = (score / total * 100).round();
    final xp      = session.xpEarned == 0 ? 40 : session.xpEarned;
    final stars   = session.starsEarned == 0 ? 16 : session.starsEarned;
    final amazing = pct >= 80;

    return Scaffold(
      backgroundColor: AppColours.kidBg,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(children: [
          // Trophy
          Padding(padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(amazing ? '🏆' : '💪',
              style: const TextStyle(fontSize: 72)))
              .animate().scale(begin: const Offset(.4, .4), duration: 600.ms, curve: Curves.elasticOut),

          Text(amazing ? 'Amazing! 🎉' : 'Good try! 💪',
            style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: AppColours.textDark))
              .animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(begin: .2, end: 0),

          const SizedBox(height: 4),
          Text('⚡ Quiz · ${session.subject.isEmpty ? "Fractions" : session.subject}',
            style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textMuted))
              .animate(delay: 250.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // Score box
          Container(padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColours.line)),
            child: Column(children: [
              Text('YOUR SCORE', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800,
                color: AppColours.textMuted, letterSpacing: .5)),
              const SizedBox(height: 8),
              RichText(text: TextSpan(
                style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: AppColours.green),
                children: [
                  TextSpan(text: '$score', style: const TextStyle(fontSize: 56)),
                  TextSpan(text: ' / $total', style: const TextStyle(fontSize: 28, color: AppColours.textMuted)),
                ])),
              const SizedBox(height: 10),
              // Answer checks
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(total, (i) {
                  final correct = i < session.answerHistory.length
                      ? session.answerHistory[i] : i < score;
                  return Padding(padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(correct ? '✅' : '❌', style: const TextStyle(fontSize: 22)));
                })),
            ])).animate(delay: 300.ms).fadeIn(duration: 300.ms).slideY(begin: .1, end: 0),

          const SizedBox(height: 12),

          // Earned tiles
          Row(children: [
            _EarnedTile('⭐ +$stars', 'Stars', AppColours.kidYellow),
            const SizedBox(width: 10),
            _EarnedTile('⚡ +$xp', 'XP earned', AppColours.kidPurple),
          ]).animate(delay: 380.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 12),

          // Review note
          if (score < total)
            Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColours.line)),
              child: RichText(text: TextSpan(
                style: GoogleFonts.nunito(fontSize: 13, color: AppColours.textMuted, height: 1.6),
                children: [
                  TextSpan(text: 'You got ${total - score} wrong 💪\n',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColours.textDark)),
                  const TextSpan(text: 'Review the explanations below — understanding these means you can answer similar questions with confidence.'),
                ]))).animate(delay: 420.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 12),

          // See all answers button
          GestureDetector(onTap: () {},
            child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColours.line)),
              child: Center(child: Text('📖 See All Answers + Explanations',
                style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.textInk)))))
              .animate(delay: 460.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 12),

          // CTA row
          Row(children: [
            Expanded(child: GestureDetector(onTap: () {
              ref.read(quizSessionNotifierProvider.notifier).reset();
              context.go(AppRoutes.quiz);
            }, child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColours.line)),
              child: Center(child: Text('Try Again', style: GoogleFonts.nunito(
                fontSize: 15, fontWeight: FontWeight.w800, color: AppColours.textInk)))))),
            const SizedBox(width: 10),
            Expanded(child: Kid3dButton(
              label: '🏠 Home',
              onPressed: () { ref.read(quizSessionNotifierProvider.notifier).reset(); context.go(AppRoutes.kid); },
              colour: AppColours.kidBlue,
              darkColour: AppColours.kidBlueDark,
              fontSize: 15,
            )),
          ]).animate(delay: 500.ms).fadeIn(duration: 300.ms),
        ]),
      )),
    );
  }
}

class _EarnedTile extends StatelessWidget {
  const _EarnedTile(this.value, this.label, this.colour);
  final String value, label;
  final Color colour;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.line)),
      child: Column(children: [
        Text(value, style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: colour)),
        const SizedBox(height: 3),
        Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
      ])),
  );
}

// ═══════════════════════════════════════════════════════
// S21 · REWARDS & BADGES SCREEN
// ═══════════════════════════════════════════════════════

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  static const _badges = [
    _Badge('🥇', 'Maths Starter',     true,  true),
    _Badge('⭐', 'Spelling Star',      true,  false),
    _Badge('🃏', 'Flashcard Hero',    true,  false),
    _Badge('🔬', 'Science Explorer',  false, false),
    _Badge('🏆', 'Quiz Champion',     false, false),
    _Badge('🔥', '7-Day Learner',     false, false),
    _Badge('✏️', 'Practice Pro',      false, false),
    _Badge('🚀', 'Super Learner',     false, false),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(activeChildProvider);
    final child      = childAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColours.kidBg,
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(children: [
            GestureDetector(onTap: () => context.go(AppRoutes.kid),
              child: const Icon(Icons.arrow_back_ios, color: AppColours.textDark, size: 20)),
            Expanded(child: Center(child: Text('My Rewards 🏆',
              style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: AppColours.textDark)))),
            const SizedBox(width: 30),
          ])),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Stats card
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColours.line)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('⭐', style: TextStyle(fontSize: 44)),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${child?.stars ?? 240}', style: GoogleFonts.nunito(
                      fontSize: 38, fontWeight: FontWeight.w900, color: AppColours.textDark)),
                    Text('Total Stars', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
                  ]),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _MiniStat('⚡', '${child?.xp ?? 340} XP', AppColours.kidPurple),
                  const SizedBox(width: 20),
                  _MiniStat('🔥', '${child?.streak ?? 4} streak', AppColours.kidPink),
                ]),
              ])).animate().fadeIn(duration: 300.ms).slideY(begin: .05, end: 0),

            const SizedBox(height: 14),

            // Unlock progress
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(15)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('✏️ Science Explorer', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.textDark)),
                  const SizedBox(height: 2),
                  Text('2 more quizzes to unlock!', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('3/5', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.blue)),
                  const SizedBox(height: 5),
                  Container(width: 44, height: 5, decoration: BoxDecoration(color: AppColours.line, borderRadius: BorderRadius.circular(99)),
                    child: FractionallySizedBox(widthFactor: .6, alignment: Alignment.centerLeft,
                      child: Container(decoration: BoxDecoration(color: AppColours.blue, borderRadius: BorderRadius.circular(99))))),
                ]),
              ])).animate(delay: 80.ms).fadeIn(duration: 300.ms),

            const SizedBox(height: 16),

            // Badges label
            Text('BADGES · ${_badges.where((b) => b.earned).length} of ${_badges.length}',
              style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900,
                color: AppColours.textMuted, letterSpacing: .8)),
            const SizedBox(height: 9),

            // Badges grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .9,
              children: _badges.asMap().entries.map((e) =>
                  _BadgeCard(badge: e.value)
                      .animate(delay: Duration(milliseconds: 100 + e.key * 40))
                      .fadeIn(duration: 250.ms)
                      .scale(begin: const Offset(.85, .85))).toList(),
            ),
          ]),
        )),
      ])),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.emoji, this.label, this.colour);
  final String emoji, label;
  final Color colour;

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 16)),
    const SizedBox(width: 6),
    Text(label, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: colour)),
  ]);
}

class _Badge {
  const _Badge(this.emoji, this.label, this.earned, this.isNew);
  final String emoji, label;
  final bool earned, isNew;
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final _Badge badge;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: badge.earned ? null : Colors.white,
      gradient: badge.earned
          ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFFFFBEB), Colors.white])
          : null,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: badge.earned ? AppColours.kidYellow : AppColours.line,
        width: badge.earned ? 2 : 1.5,
      ),
    ),
    child: Stack(children: [
      if (badge.isNew)
        Positioned(top: -1, left: 0, right: 0,
          child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColours.kidYellow, borderRadius: BorderRadius.circular(99)),
            child: Text('NEW', style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF78350F)))))),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(badge.emoji,
          style: TextStyle(fontSize: 30, color: badge.earned ? null : Colors.grey.withOpacity(.4))),
        const SizedBox(height: 6),
        Text(badge.label, textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800,
            color: badge.earned ? AppColours.textDark : AppColours.textMuted)),
        if (!badge.earned) ...[
          const SizedBox(height: 3),
          const Text('🔒', style: TextStyle(fontSize: 13)),
        ],
      ]),
    ]),
  );
}
