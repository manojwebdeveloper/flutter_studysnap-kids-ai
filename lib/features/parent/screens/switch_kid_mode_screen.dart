// Remaining parent screens — Switch Kid Mode, Practice Questions,
// Study Sets, Curriculum Topic, Progress, Practice Areas, Settings, Subscription
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/parent_provider.dart';

// ═══════════════════════════════════════════════════════
// S16 · SWITCH TO KID MODE
// ═══════════════════════════════════════════════════════

class SwitchKidModeScreen extends ConsumerWidget {
  const SwitchKidModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenStreamProvider);
    final selected = ref.watch(selectedChildNotifierProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColours.bg,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Align(alignment: Alignment.centerLeft,
            child: GestureDetector(onTap: () => context.go(AppRoutes.parent),
              child: const Icon(Icons.close, color: AppColours.textMuted, size: 26)))),
        Expanded(child: Center(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(children: [
            const Text('🎒', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            const Text('Ready to Learn?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColours.textDark, letterSpacing: -.3)),
            const SizedBox(height: 8),
            const Text('Kid Mode only shows activities you\'ve approved.',
              textAlign: TextAlign.center, style: AppTextStyles.body),
            const SizedBox(height: 28),
            const Align(alignment: Alignment.centerLeft,
              child: Text('CHOOSE LEARNER', style: AppTextStyles.sectionLabel)),
            const SizedBox(height: 9),
            childrenAsync.when(
              data: (children) => Column(children: children.map((c) {
                final isSel = selected?.id == c.id;
                return GestureDetector(
                  onTap: () => ref.read(selectedChildNotifierProvider.notifier).selectChild(c.id),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSel ? AppColours.blueLight : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSel ? AppColours.blue : AppColours.line, width: 2)),
                    child: Row(children: [
                      Container(width: 52, height: 52, decoration: BoxDecoration(
                        color: AppColours.subtle, shape: BoxShape.circle,
                        border: Border.all(color: isSel ? AppColours.blue : AppColours.line, width: 2)),
                        child: Center(child: Text(c.avatar, style: const TextStyle(fontSize: 24)))),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.nickname, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.textDark)),
                        const SizedBox(height: 2),
                        Text('${c.yearGroup} · 6 approved sets',
                          style: const TextStyle(fontSize: 13, color: AppColours.textMuted)),
                      ]),
                    ])),
                );
              }).toList()),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(16)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('🛡', style: TextStyle(fontSize: 22)),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Kid Mode is safe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textDark)),
                  SizedBox(height: 3),
                  Text('No purchases, no external links, no chat. To return to Parent Mode, enter your PIN.',
                    style: TextStyle(fontSize: 13, color: AppColours.textMuted, height: 1.55)),
                ])),
              ])),
          ]),
        ))),
        Padding(padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
          child: PrimaryButton(label: 'Start Kid Mode', onPressed: () => context.go(AppRoutes.kid))),
      ])),
    );
  }
}

// ═══════════════════════════════════════════════════════
// sPQ · PRACTICE QUESTIONS SCREEN
// ═══════════════════════════════════════════════════════

class PracticeQuestionsScreen extends StatefulWidget {
  const PracticeQuestionsScreen({super.key});
  @override State<PracticeQuestionsScreen> createState() => _PracticeQuestionsScreenState();
}

class _PracticeQuestionsScreenState extends State<PracticeQuestionsScreen> {
  int _level = 1; // 0=Easier, 1=Standard, 2=Harder
  static const _levelLabels = ['Easier', 'Standard', 'Harder'];

  static const _questions = [
    ('Write three fractions equivalent to 1/2.', '2/4, 3/6, 4/8 (any three correct)', '3 marks'),
    ('Circle the larger fraction: 2/5 or 3/5. Explain your answer.', '3/5 — same denominator, bigger numerator.', '2 marks'),
    ('Shade 3/8 of this rectangle.', 'Shade 3 out of 8 equal sections.', '2 marks'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColours.bg,
    appBar: AppBar(backgroundColor: AppColours.bg, elevation: 0,
      leading: GestureDetector(onTap: () => context.go(AppRoutes.studySetReady),
        child: const Row(children: [
          SizedBox(width: 8),
          Icon(Icons.arrow_back_ios, color: AppColours.blue, size: 20),
          Text('Practice Questions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textDark)),
        ])),
      actions: [
        TextButton.icon(onPressed: () {}, icon: const Text('🖨'),
          label: const Text('Print', style: TextStyle(color: AppColours.blue, fontWeight: FontWeight.w700))),
        TextButton.icon(onPressed: () {}, icon: const Text('⬇'),
          label: const Text('PDF', style: TextStyle(color: AppColours.blue, fontWeight: FontWeight.w700))),
      ]),
    body: SafeArea(child: Column(children: [
      Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
        // Header
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Equivalent Fractions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.textDark)),
          const SizedBox(height: 4),
          const Text('Maths · Year 4 · Age 8–10 · 20 questions',
            style: TextStyle(fontSize: 12, color: AppColours.textMuted)),
          const SectionLabel('LEVEL'),
          Row(children: List.generate(3, (i) => GestureDetector(
            onTap: () => setState(() => _level = i),
            child: AnimatedContainer(duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _level == i ? AppColours.blue : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _level == i ? AppColours.blue : AppColours.line, width: 1.5)),
              child: Text(_levelLabels[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: _level == i ? Colors.white : AppColours.textMuted))),
          ))),
        ])),
        ..._questions.asMap().entries.map((e) => AppCard(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${e.key + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.blue)),
            const SizedBox(height: 6),
            Text(e.value.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textDark)),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColours.greenLight, borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(color: AppColours.green, width: 3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MARK SCHEME · ${e.value.$3}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColours.green, letterSpacing: .5)),
                const SizedBox(height: 4),
                Text(e.value.$2, style: const TextStyle(fontSize: 13, color: AppColours.textInk)),
              ])),
          ]))),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Row(children: [
          Expanded(child: GestureDetector(onTap: () {},
            child: Container(height: 54, decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('🖨 Print PDF', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColours.textInk)))))),
          const SizedBox(width: 10),
          Expanded(child: PrimaryButton(label: '⬇ Download PDF', onPressed: () {})),
        ])),
    ])),
  );
}

// ═══════════════════════════════════════════════════════
// sSS · STUDY SETS SCREEN
// ═══════════════════════════════════════════════════════

class StudySetsScreen extends ConsumerStatefulWidget {
  const StudySetsScreen({super.key});
  @override ConsumerState<StudySetsScreen> createState() => _StudySetsScreenState();
}

class _StudySetsScreenState extends ConsumerState<StudySetsScreen> {
  bool _mysets = true;

  @override
  Widget build(BuildContext context) {
    final setsAsync = ref.watch(studySetsStreamProvider);
    final childrenAsync = ref.watch(childrenStreamProvider);
    final child = ref.watch(selectedChildNotifierProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColours.bg,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(children: [
            const Text('Study Sets', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColours.textDark)),
            const Spacer(),
            GestureDetector(onTap: () => context.go(AppRoutes.ocrReview),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColours.teal, borderRadius: BorderRadius.circular(12)),
                child: const Text('+ New Scan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)))),
          ])),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // My Sets / Curriculum tabs
            Container(padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                _TabBtn('📁 My Sets', _mysets, () => setState(() => _mysets = true)),
                _TabBtn('📚 Curriculum', !_mysets, () => setState(() => _mysets = false)),
              ])),
            const SizedBox(height: 14),

            // Kid filter
            childrenAsync.when(
              data: (children) => SizedBox(height: 42, child: ListView(scrollDirection: Axis.horizontal,
                children: children.map((c) {
                  final sel = child?.id == c.id;
                  return GestureDetector(
                    onTap: () => ref.read(selectedChildNotifierProvider.notifier).selectChild(c.id),
                    child: AnimatedContainer(duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? AppColours.blueLight : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: sel ? AppColours.blue : AppColours.line, width: 2)),
                      child: Row(children: [
                        Text(c.avatar, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(c.nickname, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                          color: sel ? AppColours.blue : AppColours.textDark)),
                      ])));
                }).toList())),
              loading: () => const SizedBox(height: 42),
              error: (_, __) => const SizedBox(height: 42),
            ),
            const SizedBox(height: 12),

            setsAsync.when(
              data: (sets) {
                if (sets.isEmpty) return const _EmptyStudySets();
                return Column(children: sets.map((s) => _StudySetCard(set: s)).toList());
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ]),
        )),
      ])),
      bottomNavigationBar: _ParentBottomNav(current: 2),
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn(this.label, this.active, this.onTap);
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 4)] : []),
      child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
        color: active ? AppColours.textDark : AppColours.textMuted))))));
}

class _StudySetCard extends StatelessWidget {
  const _StudySetCard({required this.set});
  final dynamic set;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColours.line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(_emoji(set.subject), style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Text(set.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColours.textDark))),
        StatusPill(set.status),
        const SizedBox(width: 6),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(99)),
          child: const Text('Scanned', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColours.textMuted))),
      ]),
      const SizedBox(height: 4),
      Text('${set.subject} · ${_dateStr(set.createdAt)}',
        style: const TextStyle(fontSize: 12, color: AppColours.textMuted)),
      const SizedBox(height: 8),
      Row(children: [
        _Count('🃏', '${set.cardCount} cards'),
        const SizedBox(width: 12),
        _Count('🎯', '${set.questionCount}Q'),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _ActionBtn('📖 Study', () {}),
        const SizedBox(width: 8),
        _ActionBtn('✨ Generate', () => context.go(AppRoutes.chooseOutput)),
        const SizedBox(width: 8),
        _ActionBtn('🖨 Print', () => context.go(AppRoutes.practiceQ)),
      ]),
    ]),
  );

  String _emoji(String subject) => switch (subject) {
    'Maths' => '➗', 'English' => '📖', 'Science' => '🧪', 'Spelling' => '✏️', _ => '📚'};
  String _dateStr(DateTime dt) => '${dt.day} ${['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][dt.month]}';
}

class _Count extends StatelessWidget {
  const _Count(this.emoji, this.label);
  final String emoji, label;
  @override Widget build(BuildContext context) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 13)),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
  ]);
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
  @override Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(11)),
      child: Center(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.textInk))))));
}

class _EmptyStudySets extends StatelessWidget {
  const _EmptyStudySets();
  @override Widget build(BuildContext context) => AppCard(child: const Column(children: [
    SizedBox(height: 16),
    Text('☐', style: TextStyle(fontSize: 48)),
    SizedBox(height: 10),
    Text('No study sets yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.textDark)),
    SizedBox(height: 6),
    Text('Scan a worksheet to get started.', textAlign: TextAlign.center, style: AppTextStyles.bodySmall),
    SizedBox(height: 16),
  ]));
}

class _ParentBottomNav extends StatelessWidget {
  const _ParentBottomNav({required this.current});
  final int current;
  @override Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: current,
    onTap: (i) {
      final routes = [AppRoutes.parent, AppRoutes.scan, AppRoutes.studySets, AppRoutes.progress, AppRoutes.settings];
      context.go(routes[i]);
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.crop_free), label: 'Scan'),
      BottomNavigationBarItem(icon: Icon(Icons.layers_outlined), activeIcon: Icon(Icons.layers), label: 'Study Sets'),
      BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Progress'),
      BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
    ]);
}

// ═══════════════════════════════════════════════════════
// sCT · CURRICULUM TOPIC
// ═══════════════════════════════════════════════════════

class CurriculumTopicScreen extends StatelessWidget {
  const CurriculumTopicScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColours.bg,
    appBar: AppBar(backgroundColor: AppColours.bg, elevation: 0,
      leading: GestureDetector(onTap: () => context.go(AppRoutes.studySets),
        child: const Row(children: [
          SizedBox(width: 8), Icon(Icons.arrow_back_ios, color: AppColours.blue, size: 20),
          Text('Fractions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.textDark)),
        ])),
      actions: [
        TextButton(onPressed: () {}, child: const Text('+ Assign',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
            backgroundColor: AppColours.blue))),
      ]),
    body: SafeArea(child: Column(children: [
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
        Wrap(spacing: 7, children: [
          SubjectBadge('Maths'),
          _SmallTag('Year 4', AppColours.amberLight, AppColours.amber),
          _SmallTag('Age 8–10', AppColours.tealLight, AppColours.teal),
        ]),
        const SizedBox(height: 18),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Text('💡', style: TextStyle(fontSize: 20)), SizedBox(width: 8),
            Text('Parent Explanation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.textDark))]),
          const SizedBox(height: 12),
          const Text(
            'A fraction shows part of a whole. The number on the bottom is called the denominator — '
            'it tells you how many equal parts the whole is split into. The number on top is the '
            'numerator — it tells you how many of those parts you have.\n\n'
            'Two fractions are equivalent when they show the same amount — for example, ½ = 2/4 = 4/8.',
            style: TextStyle(fontSize: 14, color: AppColours.textInk, height: 1.75)),
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColours.tealLight,
              border: Border(left: BorderSide(color: AppColours.teal, width: 3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('HOW TO EXPLAIN AT HOME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                color: AppColours.teal, letterSpacing: .5)),
              SizedBox(height: 4),
              Text('Try cutting a pizza or chocolate bar into equal pieces. Ask: "If I cut it into 4 pieces and you eat 2, what fraction did you eat?"',
                style: TextStyle(fontSize: 13, color: AppColours.textInk, height: 1.6)),
            ])),
        ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Topics Covered', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.textDark)),
          const SizedBox(height: 10),
          _TopicRow('📝', 'What is a fraction?'),
          _TopicRow('🔢', 'Numerator & denominator'),
          _TopicRow('🔄', 'Equivalent fractions', isLast: true),
        ])),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Row(children: [
          Expanded(child: PrimaryButton(label: '🃏 Study Now', onPressed: () => context.go(AppRoutes.flashcards))),
          const SizedBox(width: 10),
          Expanded(child: GestureDetector(onTap: () => context.go(AppRoutes.chooseOutput),
            child: Container(height: 54, decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('✨ Generate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColours.textInk)))))),
        ])),
    ])),
  );
}

class _SmallTag extends StatelessWidget {
  const _SmallTag(this.label, this.bg, this.fg);
  final String label;
  final Color bg, fg;
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg)));
}

class _TopicRow extends StatelessWidget {
  const _TopicRow(this.emoji, this.label, {this.isLast = false});
  final String emoji, label;
  final bool isLast;
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColours.line))),
    child: Row(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(9)),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16)))),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textInk))),
      const Icon(Icons.chevron_right, color: AppColours.textMuted),
    ]));
}

// ═══════════════════════════════════════════════════════
// S22 · PARENT PROGRESS
// ═══════════════════════════════════════════════════════

class ParentProgressScreen extends ConsumerStatefulWidget {
  const ParentProgressScreen({super.key});
  @override ConsumerState<ParentProgressScreen> createState() => _ParentProgressState();
}

class _ParentProgressState extends ConsumerState<ParentProgressScreen> {
  bool _7days = true;
  static const _subjects = [
    ('📖 English', 0.88, AppColours.blue,   'Doing well'),
    ('✏️ Spelling', 0.82, AppColours.teal,  'On track'),
    ('➗ Maths',   0.64, AppColours.amber,  'Needs practice'),
    ('🧪 Science', 0.71, AppColours.blue,   'Getting better'),
  ];

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(selectedChildNotifierProvider).valueOrNull;
    final childrenAsync = ref.watch(childrenStreamProvider);

    return Scaffold(
      backgroundColor: AppColours.bg,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 10), child: Row(children: [
          GestureDetector(onTap: () => context.go(AppRoutes.parent),
            child: Row(children: [const Icon(Icons.arrow_back_ios, color: AppColours.blue, size: 20),
              const Text('Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColours.textDark))])),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(99)),
            child: Row(children: [
              _PeriodBtn('7 days', _7days, () => setState(() => _7days = true)),
              _PeriodBtn('30 days', !_7days, () => setState(() => _7days = false)),
            ])),
        ])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
          // Kid tabs
          childrenAsync.when(
            data: (children) => Row(children: children.map((c) {
              final sel = child?.id == c.id;
              return GestureDetector(
                onTap: () => ref.read(selectedChildNotifierProvider.notifier).selectChild(c.id),
                child: AnimatedContainer(duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 9),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColours.blueLight : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: sel ? AppColours.blue : AppColours.line, width: 2)),
                  child: Row(children: [
                    Text(c.avatar, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.nickname, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                        color: sel ? AppColours.blue : AppColours.textDark)),
                      Text(c.yearGroup, style: const TextStyle(fontSize: 11, color: AppColours.textMuted)),
                    ]),
                  ])));
            }).toList()),
            loading: () => const SizedBox(height: 52), error: (_, __) => const SizedBox(height: 52)),
          const SizedBox(height: 16),

          // Stat tiles
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.6,
            children: const [
              _StatTile('🃏 Flashcards', '86', '↑ +12', AppColours.green),
              _StatTile('🎯 Avg quiz', '78%', '↑ +6%', AppColours.green),
              _StatTile('⭐ Stars', '240', '↑ +42', AppColours.green),
              _StatTile('🔥 Streak', '4 days', '· best 7', AppColours.textMuted),
            ]),
          const SizedBox(height: 14),

          // Scores by subject
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Scores by Subject', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.textDark)),
            const SizedBox(height: 14),
            ..._subjects.map((s) => Padding(padding: const EdgeInsets.only(bottom: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(s.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textInk)),
                  Text('${(s.$2 * 100).round()}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: s.$3)),
                ]),
                const SizedBox(height: 5),
                ScoreProgressBar(value: s.$2, colour: s.$3),
                const SizedBox(height: 4),
                Text(s.$4, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: s.$3)),
              ]))),
          ])),

          // Insight
          Container(padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: AppColours.blueLight,
              border: Border.all(color: AppColours.blueMid),
              borderRadius: BorderRadius.circular(15)),
            child: RichText(text: const TextSpan(
              style: TextStyle(fontSize: 13, color: AppColours.textInk, height: 1.6),
              children: [
                TextSpan(text: '💡 '),
                TextSpan(text: 'Aarav is doing well in spelling. ',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColours.blue)),
                TextSpan(text: 'Needs more practice with fractions. '),
                TextSpan(text: 'Tap to create a focused set.',
                  style: TextStyle(color: AppColours.blue, fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline)),
              ]))),
          const SizedBox(height: 20),
        ])),
      ])),
      bottomNavigationBar: _ParentBottomNav(current: 3),
    );
  }
}

class _PeriodBtn extends StatelessWidget {
  const _PeriodBtn(this.label, this.active, this.onTap);
  final String label; final bool active; final VoidCallback onTap;
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 4)] : []),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
        color: active ? AppColours.textDark : AppColours.textMuted))));
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.label, this.value, this.change, this.changeColour);
  final String label, value, change; final Color changeColour;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(15)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColours.textDark)),
      const SizedBox(height: 3),
      Text(change, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: changeColour)),
    ]));
}

// ═══════════════════════════════════════════════════════
// S23 · PRACTICE AREAS (stub — full impl same pattern)
// S24 · SETTINGS
// S25 · SUBSCRIPTION
// ═══════════════════════════════════════════════════════

class PracticeAreasScreen extends StatelessWidget {
  const PracticeAreasScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColours.bg,
    appBar: AppBar(backgroundColor: AppColours.bg, elevation: 0,
      leading: GestureDetector(onTap: () => context.go(AppRoutes.progress),
        child: const Row(children: [SizedBox(width: 8),
          Icon(Icons.arrow_back_ios, color: AppColours.blue, size: 20),
          Text('Practice Areas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.textDark))]))),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Aarav · Year 4', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textDark)),
      const SizedBox(height: 4),
      const Text('These topics could use a bit more practice.', style: AppTextStyles.bodySmall),
      const SizedBox(height: 16),
      ...[
        ('➗', 'Equivalent Fractions', 'Maths · 62%', '↓ 8%', true),
        ('✏️', 'Silent Letters', 'Spelling · 70%', '↑ 4%', false),
        ('🌿', 'Photosynthesis', 'Science · 68%', '—', false),
        ('📖', 'Apostrophes', 'English · 74%', '↑ 6%', false),
      ].map((item) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColours.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(item.$1, style: const TextStyle(fontSize: 18)))),
            const SizedBox(width: 10),
            Expanded(child: Text(item.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.textDark))),
            Text(item.$4, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: item.$4.startsWith('↓') ? AppColours.red : item.$4 == '—' ? AppColours.textMuted : AppColours.green)),
          ]),
          const SizedBox(height: 4),
          Text(item.$3, style: const TextStyle(fontSize: 13, color: AppColours.textMuted)),
          const SizedBox(height: 10),
          Row(children: [
            _ActionBtn('✨ Create Set', () => context.go(AppRoutes.chooseOutput)),
            const SizedBox(width: 8),
            _ActionBtn('📚 Curriculum', () {}),
            const SizedBox(width: 8),
            const Expanded(child: Text('✓ Improved', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.green), textAlign: TextAlign.center)),
          ]),
        ]))),
      const SizedBox(height: 12),
      GestureDetector(onTap: () => context.go(AppRoutes.chooseOutput),
        child: Container(padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(color: AppColours.purpleLight, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColours.purple)),
          child: const Center(child: Text('✨ Create Practice Set for All',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.purple))))),
    ])));
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _requirePin = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColours.bg,
    appBar: const AppBar(backgroundColor: AppColours.bg, elevation: 0,
      title: Text('Settings', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColours.textDark))),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
      // Upgrade banner
      Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColours.amberLight, border: Border.all(color: Color(0xFFFDE68A)),
          borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Text('✨', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Free Plan · 2 of 3 scans left', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textDark)),
            SizedBox(height: 2),
            Text('Upgrade for unlimited scans & 2 children', style: TextStyle(fontSize: 12, color: AppColours.textMuted)),
          ])),
          GestureDetector(onTap: () => context.go(AppRoutes.subscription),
            child: const Text('Upgrade', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.amber))),
        ])),
      const SectionLabel('CHILDREN'),
      _SettingCard(children: [
        _SettingRow('🚀', 'Aarav · Year 4', 'Maths · English · Science · Spelling', () {}),
        _SettingRow('🦄', 'Mira · Year 2', 'Reading · Maths', () {}),
        _SettingRowAdd(() {}),
      ]),
      const SectionLabel('SECURITY'),
      _SettingCard(children: [
        _SettingRow('🔒', 'Change Parent PIN', null, () {}),
        _SettingRowToggle('🛡', 'Require PIN for Parent Mode', _requirePin, () => setState(() => _requirePin = !_requirePin)),
      ]),
      const SectionLabel('DATA & PRIVACY'),
      _SettingCard(children: [
        const Padding(padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text('Worksheet images and study sets are saved on this device. When AI features are used, extracted text may be processed to create flashcards, quizzes and explanations.',
            style: TextStyle(fontSize: 13, color: AppColours.textMuted, height: 1.6))),
        _SettingRow('📁', 'Manage study sets', '14 sets', () {}),
        _SettingRowDanger('⚠️', 'Clear all local data', () {}),
      ]),
      const SectionLabel('APP'),
      _SettingCard(children: [
        Padding(padding: const EdgeInsets.all(14),
          child: GestureDetector(onTap: () => context.go(AppRoutes.subscription),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 14), width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColours.line, width: 1.5)),
              child: const Center(child: Text('Upgrade for unlimited scans & 2 children',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.textMuted)))))),
      ]),
      const SizedBox(height: 20),
    ])),
    bottomNavigationBar: _ParentBottomNav(current: 4),
  );
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.children});
  final List<Widget> children;
  @override Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColours.line)),
    child: Column(children: children));
}

class _SettingRow extends StatelessWidget {
  const _SettingRow(this.icon, this.label, this.sub, this.onTap);
  final String icon, label;
  final String? sub;
  final VoidCallback onTap;
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColours.line))),
      child: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 17)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.textDark)),
          if (sub != null) Text(sub!, style: const TextStyle(fontSize: 12, color: AppColours.textMuted)),
        ])),
        if (sub != null && sub!.contains('sets'))
          Text(sub!, style: const TextStyle(fontSize: 13, color: AppColours.textMuted)),
        const Icon(Icons.chevron_right, color: AppColours.textMuted),
      ])));
}

class _SettingRowAdd extends StatelessWidget {
  const _SettingRowAdd(this.onTap);
  final VoidCallback onTap;
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColours.blueLight, borderRadius: BorderRadius.circular(10)),
          child: const Center(child: Icon(Icons.add, color: AppColours.blue))),
        const SizedBox(width: 12),
        const Text('Add child', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.blue)),
        const Spacer(),
        const Icon(Icons.chevron_right, color: AppColours.blue),
      ])));
}

class _SettingRowToggle extends StatelessWidget {
  const _SettingRowToggle(this.icon, this.label, this.value, this.onToggle);
  final String icon, label; final bool value; final VoidCallback onToggle;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 17)))),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.textDark))),
      GestureDetector(onTap: onToggle,
        child: AnimatedContainer(duration: const Duration(milliseconds: 200),
          width: 48, height: 28,
          decoration: BoxDecoration(color: value ? AppColours.blue : AppColours.line, borderRadius: BorderRadius.circular(99)),
          child: AnimatedAlign(duration: const Duration(milliseconds: 200),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(margin: const EdgeInsets.all(3), width: 22, height: 22,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)])))))
    ]));
}

class _SettingRowDanger extends StatelessWidget {
  const _SettingRowDanger(this.icon, this.label, this.onTap);
  final String icon, label; final VoidCallback onTap;
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColours.redLight, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 17)))),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.red)),
      ])));
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  static const _features = [
    ('📷', 'Unlimited worksheet scans'),
    ('🃏', 'Unlimited flashcards & quizzes'),
    ('📚', 'Full curriculum library access'),
    ('👶', 'Multiple child profiles'),
    ('💡', 'Advanced explanations & guides'),
    ('✏️', 'Unlimited practice questions + PDF'),
    ('📊', 'Parent progress reports'),
    ('🚫', 'No ads, ever'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColours.bg,
    body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(0, 8, 20, 0),
        child: Align(alignment: Alignment.centerRight,
          child: TextButton(onPressed: () => context.go(AppRoutes.settings),
            child: const Text('Restore', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.textMuted))))),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 24), children: [
        const SizedBox(height: 16),
        Center(child: Container(width: 80, height: 80,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFFBEB), Color(0xFFFDE68A)]),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: AppColours.amber.withOpacity(.2), blurRadius: 24, offset: const Offset(0, 6))]),
          child: const Center(child: Text('✨', style: TextStyle(fontSize: 38))))),
        const SizedBox(height: 18),
        const Center(child: Text('Unlock More Learning',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: AppColours.textDark, letterSpacing: -.3))),
        const SizedBox(height: 8),
        const Center(child: Text('Unlimited worksheets, curriculum library access, and progress reports.',
          textAlign: TextAlign.center, style: AppTextStyles.body)),
        const SizedBox(height: 24),
        AppCard(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: _features.asMap().entries.map((e) => Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(border: e.key == _features.length - 1 ? null : const Border(bottom: BorderSide(color: AppColours.line))),
            child: Row(children: [
              Text(e.value.$1, style: const TextStyle(fontSize: 18, width: 24)),
              const SizedBox(width: 12),
              Text(e.value.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.textInk)),
              const Spacer(),
              const Text('✓', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColours.green)),
            ]))).toList())),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Monthly', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
              Text('Cancel anytime', style: TextStyle(fontSize: 12, color: AppColours.textMuted)),
            ]),
            Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text('£4.99', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColours.textDark)),
              Text(' / month', style: TextStyle(fontSize: 13, color: AppColours.textMuted)),
            ]),
          ])),
        const SizedBox(height: 20),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 28), child: Column(children: [
        PrimaryButton(label: 'Start 7-Day Free Trial', onPressed: () => context.go(AppRoutes.settings)),
        const SizedBox(height: 10),
        GestureDetector(onTap: () => context.go(AppRoutes.settings),
          child: const Text('Continue with Free Plan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.textMuted))),
      ])),
    ])),
  );
}
