import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../domain/entities/child_entity.dart';
import '../providers/kid_provider.dart';

class KidDashboardScreen extends ConsumerWidget {
  const KidDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(activeChildProvider);
    final setsAsync  = ref.watch(approvedSetsProvider);

    return Scaffold(
      backgroundColor: AppColours.kidBg,
      body: SafeArea(
        child: childAsync.when(
          data: (child) => _Body(child: child, setsAsync: setsAsync),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColours.kidBlue)),
          error: (_, __) => const Center(child: Text('Something went wrong')),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.child, required this.setsAsync});
  final ChildEntity? child;
  final AsyncValue<dynamic> setsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = child?.nickname ?? 'Learner';
    final xp       = child?.xp ?? 340;
    final stars    = child?.stars ?? 240;
    final streak   = child?.streak ?? 4;
    final level    = child?.level ?? 7;
    final progress = child?.levelProgress ?? 0.68;

    return ResponsiveBody(child: Column(
      children: [
        // ── Header ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi $nickname! 🚀',
                    style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
                  Text('Keep it up! 🔥',
                    style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: AppColours.textDark)),
                ],
              ),
              const Spacer(),
              // Hearts
              Row(
                children: List.generate(5, (i) => Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(i < 2 ? '❤️' : '🤍', style: const TextStyle(fontSize: 22)),
                )),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -.1, end: 0),

        // ── Stats bar ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              _StatBubble('🔥 $streak', 'streak'),
              _StatBubble('⭐ $stars', 'stars'),
              _StatBubble('🏆 3', 'badges'),
            ],
          ),
        ).animate(delay: 80.ms).fadeIn(duration: 300.ms),

        // ── XP bar ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Row(
            children: [
              Text('$level', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: AppColours.textMuted)),
              const Spacer(),
              Text('$xp / 500 XP', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: AppColours.textMuted)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: XpProgressBar(progress: progress),
        ),

        // ── Scrollable content ─────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Continue card
                _ContinueCard().animate(delay: 120.ms).fadeIn(duration: 300.ms).slideY(begin: .1, end: 0),
                const SizedBox(height: 16),

                // Quick practice
                Text('QUICK PRACTICE',
                  style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900,
                    color: AppColours.textMuted, letterSpacing: .8)),
                const SizedBox(height: 9),
                Row(
                  children: [
                    _QuickCard('⚡', '3 min', '~5 Qs', () => context.go(AppRoutes.quiz)),
                    const SizedBox(width: 9),
                    _QuickCard('🎯', '5 min', '~10 Qs', () => context.go(AppRoutes.quiz)),
                    const SizedBox(width: 9),
                    _QuickCard('🎲', 'Random', '10 Qs', () => context.go(AppRoutes.quiz)),
                  ],
                ).animate(delay: 160.ms).fadeIn(duration: 300.ms),
                const SizedBox(height: 16),

                // My subjects
                Text('MY SUBJECTS',
                  style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900,
                    color: AppColours.textMuted, letterSpacing: .8)),
                const SizedBox(height: 9),
                ...const [
                  _SubjectRow('➗', 'Maths',   '3/8 topics', AppColours.kidBlue,   Color(0xFFEFF6FF)),
                  _SubjectRow('📖', 'English', '5/6 topics', AppColours.kidPurple, Color(0xFFF5F3FF)),
                  _SubjectRow('🧪', 'Science', '2/5 topics', AppColours.kidGreen,  Color(0xFFF0FDFA)),
                  _SubjectRow('✏️', 'Spelling','4/4 ✓ Done!',AppColours.kidGreen,  Color(0xFFF0FDFA)),
                ].asMap().entries.map((e) =>
                    e.value.animate(delay: Duration(milliseconds: 200 + e.key * 40))
                        .fadeIn(duration: 300.ms).slideX(begin: .08, end: 0)),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

// ── Widgets ───────────────────────────────────────────────

class _StatBubble extends StatelessWidget {
  const _StatBubble(this.value, this.label);
  final String value, label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value, style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: AppColours.textDark)),
      Text(label, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: AppColours.textMuted)),
    ]),
  );
}

class _ContinueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.go(AppRoutes.learningPath),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.line),
      ),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(
          color: AppColours.blueLight, borderRadius: BorderRadius.circular(13)),
          child: const Center(child: Text('➗', style: TextStyle(fontSize: 22)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CONTINUE', style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900,
            color: AppColours.textMuted, letterSpacing: .6)),
          Text('Fractions · Unit 3', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: AppColours.textDark)),
          Text('3 lessons left · 12 min', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
          const SizedBox(height: 7),
          Container(height: 4, decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(99)),
            child: FractionallySizedBox(widthFactor: .62, alignment: Alignment.centerLeft,
              child: Container(decoration: BoxDecoration(color: AppColours.kidGreen, borderRadius: BorderRadius.circular(99))))),
        ])),
        const Icon(Icons.chevron_right, color: AppColours.kidBlue),
      ]),
    ),
  );
}

class _QuickCard extends StatelessWidget {
  const _QuickCard(this.emoji, this.label, this.sub, this.onTap);
  final String emoji, label, sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColours.line)),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 5),
          Text(label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: AppColours.textDark)),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
        ])),
    ),
  );
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow(this.emoji, this.title, this.prog, this.colour, this.bg);
  final String emoji, title, prog;
  final Color colour, bg;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.go(AppRoutes.learningPath),
    child: Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColours.line)),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 19)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: AppColours.textDark)),
          Text(prog, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
        ])),
        Icon(Icons.chevron_right, color: colour),
      ])),
  );
}
