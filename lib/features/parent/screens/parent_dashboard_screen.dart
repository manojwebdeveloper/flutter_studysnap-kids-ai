import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../domain/entities/child_entity.dart';
import '../../../domain/entities/study_set_entity.dart';
import '../providers/parent_provider.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync   = ref.watch(selectedChildNotifierProvider);
    final studySetsAsync = ref.watch(studySetsStreamProvider);
    final childrenAsync = ref.watch(childrenStreamProvider);

    return Scaffold(
      backgroundColor: AppColours.bg,
      body: SafeArea(
        child: Column(children: [
          // Top bar
          Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(children: [
              const Text('🏠', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text('Parent Dashboard',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColours.blue)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go(AppRoutes.switchKid),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.swap_horiz, color: AppColours.textMuted, size: 22)),
              ),
            ])),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Greeting
              Text(_greeting(), style: const TextStyle(fontSize: 14, color: AppColours.textMuted)),
              const SizedBox(height: 16),

              // Kids row
              childrenAsync.when(
                data: (children) => _KidsRow(children: children, ref: ref),
                loading: () => const _KidRowSkeleton(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 4),

              // Scan card
              _ScanCard(),
              const SizedBox(height: 4),

              // Study sets
              Row(children: [
                const Text('Study Sets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.textDark)),
                const Spacer(),
                GestureDetector(onTap: () => context.go(AppRoutes.studySets),
                  child: const Text('View all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.blue))),
              ]),
              const SizedBox(height: 10),
              studySetsAsync.when(
                data: (sets) => _StudySetsList(sets: sets.take(3).toList()),
                loading: () => const _CardSkeleton(),
                error: (_, __) => const SizedBox(),
              ),

              // Practice areas teaser
              const SizedBox(height: 16),
              Row(children: [
                const Text('Practice Areas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.textDark)),
                const Spacer(),
                GestureDetector(onTap: () => context.go(AppRoutes.practiceAreas),
                  child: const Text('Create set →', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.blue))),
              ]),
              const SizedBox(height: 10),
              AppCard(child: const Text('💡 Aarav could use extra practice with fractions.',
                style: TextStyle(fontSize: 13, color: AppColours.textMuted, height: 1.55))),
              const SizedBox(height: 20),
            ]),
          )),
        ]),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}

// ── Kids row ──────────────────────────────────────────────

class _KidsRow extends StatelessWidget {
  const _KidsRow({required this.children, required this.ref});
  final List<ChildEntity> children;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 88, child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        ...children.map((c) => _KidChip(child: c, ref: ref)),
        _AddKidChip(),
      ],
    ));
  }
}

class _KidChip extends StatelessWidget {
  const _KidChip({required this.child, required this.ref});
  final ChildEntity child;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedChildNotifierProvider).valueOrNull?.id == child.id;
    return GestureDetector(
      onTap: () => ref.read(selectedChildNotifierProvider.notifier).selectChild(child.id),
      child: Container(margin: const EdgeInsets.only(right: 16),
        child: Column(children: [
          AnimatedContainer(duration: const Duration(milliseconds: 200),
            width: 56, height: 56, decoration: BoxDecoration(
              color: AppColours.subtle, shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColours.blue : Colors.transparent, width: 2.5),
              boxShadow: selected ? [BoxShadow(color: AppColours.blue.withOpacity(.18), blurRadius: 8)] : [],
            ),
            child: Center(child: Text(child.avatar, style: const TextStyle(fontSize: 26)))),
          const SizedBox(height: 6),
          Text(child.nickname, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.textDark)),
        ])),
    );
  }
}

class _AddKidChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(width: 56, height: 56,
        decoration: BoxDecoration(shape: BoxShape.circle,
          border: Border.all(color: AppColours.line, width: 2, style: BorderStyle.solid)),
        child: const Center(child: Icon(Icons.add, color: AppColours.textMuted))),
      const SizedBox(height: 6),
      const Text('Add Kid', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
    ]);
  }
}

class _KidRowSkeleton extends StatelessWidget {
  const _KidRowSkeleton();
  @override Widget build(BuildContext context) => const SizedBox(height: 88);
}

// ── Scan card ─────────────────────────────────────────────

class _ScanCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(scanCountProvider);
    final used = countAsync.valueOrNull ?? 0;
    final remaining = (AppConstants.freeScanLimit - used).clamp(0, AppConstants.freeScanLimit);

    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('🖼', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        const Text('Scan a Worksheet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColours.textDark)),
        const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColours.amberLight, borderRadius: BorderRadius.circular(99)),
          child: Text('$remaining of ${AppConstants.freeScanLimit} free',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.amber))),
      ]),
      const SizedBox(height: 6),
      const Text('Turn any worksheet into a study set', style: AppTextStyles.bodySmall),
      const SizedBox(height: 14),
      Row(children: [
        _ScanOption('📷', 'Take Photo',  'Best quality', () => context.go(AppRoutes.scan)),
        const SizedBox(width: 8),
        _ScanOption('🖼', 'Upload',      'From files',   () => context.go(AppRoutes.scan)),
        const SizedBox(width: 8),
        _ScanOption('📝', 'Paste Text',  'Type or paste',() => context.go(AppRoutes.scan)),
      ]),
      const SizedBox(height: 14),
      GestureDetector(onTap: () => context.go(AppRoutes.scan),
        child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColours.line, width: 1.5)),
          child: const Center(child: Text('Start Scanning',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColours.textMuted))))),
    ]));
  }
}

class _ScanOption extends StatelessWidget {
  const _ScanOption(this.emoji, this.label, this.sub, this.onTap);
  final String emoji, label, sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(13)),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.textDark)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppColours.textMuted)),
        ])),
    ),
  );
}

// ── Study sets list ───────────────────────────────────────

class _StudySetsList extends StatelessWidget {
  const _StudySetsList({required this.sets});
  final List<StudySetEntity> sets;

  @override
  Widget build(BuildContext context) {
    if (sets.isEmpty) {
      return AppCard(child: const Center(
        child: Padding(padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('No study sets yet. Scan a worksheet to get started!',
            textAlign: TextAlign.center, style: AppTextStyles.bodySmall))));
    }
    return AppCard(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(children: sets.asMap().entries.map((e) {
        final set = e.value;
        final isLast = e.key == sets.length - 1;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColours.line))),
          child: Row(children: [
            Text(_subjectEmoji(set.subject), style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(set.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textDark)),
              Text('${set.subject} · ${set.cardCount} cards · ${set.questionCount}Q',
                style: const TextStyle(fontSize: 12, color: AppColours.textMuted)),
            ])),
            StatusPill(set.status),
          ]),
        );
      }).toList()),
    );
  }

  String _subjectEmoji(String subject) => switch (subject) {
    'Maths'    => '➗',
    'English'  => '📖',
    'Science'  => '🧪',
    'Spelling' => '✏️',
    _          => '📚',
  };
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();
  @override Widget build(BuildContext context) => AppCard(
    child: SizedBox(height: 80,
      child: Center(child: CircularProgressIndicator(color: AppColours.blue.withOpacity(.4), strokeWidth: 2))));
}
