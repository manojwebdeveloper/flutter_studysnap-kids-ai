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

const _greyscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);

class KidDashboardScreen extends ConsumerWidget {
  const KidDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(activeChildProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColours.kidBackground,
      body: childAsync.when(
        data: (child) => _Body(child: child),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColours.kidBlue)),
        error: (_, __) => const Center(child: Text('Something went wrong')),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.child});
  final ChildEntity? child;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + 8;
    final nickname = child?.nickname ?? 'Learner';
    final xp = child?.xp ?? 340;
    final stars = child?.stars ?? 240;
    final streak = child?.streak ?? 4;
    final level = child?.level ?? 7;
    final progress = child?.levelProgress ?? 0.68;

    return Column(
      children: [
        // ── Gradient header (bleeds into status bar) ──────────
        Container(
          padding: EdgeInsets.fromLTRB(20, topPad, 20, 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColours.kidBlue, AppColours.kidPurple],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Center(child: Text('🚀', style: TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi $nickname',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.8))),
                        Text('Keep it up! 🔥',
                            style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      final active = i < 2;
                      final heart = const Text('❤️', style: TextStyle(fontSize: 20));
                      return Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: active
                            ? heart
                            : Opacity(opacity: 0.3, child: ColorFiltered(colorFilter: _greyscale, child: heart)),
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(11)),
                      child: const Center(child: Icon(Icons.lock_outline, color: Colors.white, size: 18)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: KidStatBubble(emoji: '🔥', value: '$streak', label: 'Streak')),
                  const SizedBox(width: 8),
                  Expanded(child: KidStatBubble(emoji: '⭐', value: '$stars', label: 'Stars')),
                  const SizedBox(width: 8),
                  Expanded(child: KidStatBubble(emoji: '🏆', value: '3', label: 'Badges')),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(colors: [AppColours.kidYellow, AppColours.kidPink]),
                    ),
                    child: Center(
                      child: Text('$level', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(999)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$xp / 500 XP',
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.85))),
                ],
              ),
            ],
          ),
        ),
        // ── Scrollable content ────────────────────────────────
        Expanded(
          child: Container(
            color: AppColours.kidBackground,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.learningPath),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColours.kidGreen, AppColours.kidGreenDark],
                        ),
                        boxShadow: [BoxShadow(color: AppColours.kidGreen.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(13)),
                            child: const Center(child: Text('➗', style: TextStyle(fontSize: 22))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CONTINUE',
                                    style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.8), letterSpacing: 0.6)),
                                Text('Fractions · Unit 3',
                                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                                Text('3 lessons left · 12 min',
                                    style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.85))),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 18),
                  Text('QUICK PRACTICE',
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900, color: AppColours.kidMuted, letterSpacing: 0.8)),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      _QuickCard('⚡', '3 min', '~5 Qs', () => context.go(AppRoutes.quiz)),
                      const SizedBox(width: 9),
                      _QuickCard('🎯', '5 min', '~10 Qs', () => context.go(AppRoutes.quiz)),
                      const SizedBox(width: 9),
                      _QuickCard('🎲', 'Random', '10 Qs', () => context.go(AppRoutes.quiz)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('MY SUBJECTS',
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900, color: AppColours.kidMuted, letterSpacing: 0.8)),
                  const SizedBox(height: 9),
                  _subject('➗', 'Maths', AppColours.kidBlue, 3, 8, context),
                  const SizedBox(height: 10),
                  _subject('📖', 'English', AppColours.kidPurple, 5, 6, context),
                  const SizedBox(height: 10),
                  _subject('🧪', 'Science', AppColours.kidGreen, 2, 5, context),
                  const SizedBox(height: 10),
                  _subject('✏️', 'Spelling', AppColours.kidGreen, 4, 4, context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _subject(String emoji, String name, Color colour, int done, int total, BuildContext context) =>
      GestureDetector(
        onTap: () => context.go(AppRoutes.learningPath),
        child: SubjectProgressRow(subject: name, emoji: emoji, colour: colour, done: done, total: total),
      );
}

class _QuickCard extends StatelessWidget {
  const _QuickCard(this.emoji, this.label, this.sub, this.onTap);
  final String emoji, label, sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColours.line),
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 5),
                Text(label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                const SizedBox(height: 2),
                Text(sub, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppColours.kidMuted)),
              ],
            ),
          ),
        ),
      );
}
