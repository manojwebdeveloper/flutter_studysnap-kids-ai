import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../domain/entities/child_entity.dart';
import '../../../domain/entities/study_set_entity.dart';
import '../../parent/providers/insights_provider.dart';
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
    final sets = ref.watch(approvedSetsProvider).valueOrNull ?? const <StudySetEntity>[];
    final badges = ref.watch(kidBadgesProvider).valueOrNull ?? const [];
    final badgeCount = badges.where((b) => b.isEarned).length;
    final content = childAsync.when(
      data: (child) => _Body(
        child: child,
        continueSet: sets.isEmpty ? null : sets.first,
        badgeCount: badgeCount,
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppColours.kidBlue)),
      error: (_, __) => const Center(child: Text('Something went wrong')),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColours.kidBackground,
      body: isTablet(context)
          ? Row(
              children: [
                const _KidSidebar(),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }
}

// ── Tablet sidebar (kid) ──────────────────────────────────
class _KidSidebar extends StatelessWidget {
  const _KidSidebar();

  static const _items = [
    ('🏠', 'Home', AppRoutes.kid),
    ('🗺️', 'Learning Path', AppRoutes.learningPath),
    ('🏆', 'Rewards', AppRoutes.rewards),
  ];

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).matchedLocation;
    return Container(
      width: 260,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: [AppColours.kidBlue, AppColours.kidPurple]),
                    ),
                    child: const Center(child: Text('🚀', style: TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 10),
                  Text('StudySnap',
                      style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                ],
              ),
            ),
            ..._items.map((item) {
              final active = current == item.$3;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: GestureDetector(
                  onTap: () => context.go(item.$3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: active ? AppColours.kidBlue.withOpacity(0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(item.$1, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text(item.$2,
                            style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: active ? AppColours.kidBlueDark : AppColours.kidMuted)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.child, this.continueSet, this.badgeCount = 0});
  final ChildEntity? child;
  final StudySetEntity? continueSet;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + 8;
    final nickname = child?.nickname ?? 'Learner';
    final xp = child?.xp ?? 0;
    final stars = child?.stars ?? 0;
    final streak = child?.streak ?? 0;
    final level = child?.level ?? 1;
    final progress = child?.levelProgress ?? 0.0;
    final subjects = child?.subjects ?? const <String>[];

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
                  Expanded(child: KidStatBubble(emoji: '🏆', value: '$badgeCount', label: 'Badges')),
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
                                Text(continueSet != null ? 'CONTINUE' : 'GET STARTED',
                                    style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.8), letterSpacing: 0.6)),
                                Text(continueSet?.title ?? 'Start learning',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                                Text(continueSet?.subject ?? 'Open your learning path',
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
                  if (subjects.isNotEmpty) ...[
                    Text('MY SUBJECTS',
                        style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900, color: AppColours.kidMuted, letterSpacing: 0.8)),
                    const SizedBox(height: 9),
                    for (final s in subjects) ...[
                      _subject(_subjectEmoji(s), s, _subjectColour(s), 0, 0, context),
                      const SizedBox(height: 10),
                    ],
                  ],
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

  static String _subjectEmoji(String subject) => switch (subject) {
        'Maths' => '➗',
        'English' => '📖',
        'Science' => '🧪',
        'Spelling' => '✏️',
        'Reading' => '📚',
        _ => '📘',
      };

  static Color _subjectColour(String subject) => switch (subject) {
        'Maths' => AppColours.kidBlue,
        'English' => AppColours.kidPurple,
        'Science' => AppColours.kidGreen,
        'Spelling' => AppColours.kidPink,
        _ => AppColours.kidBlue,
      };
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
