// Switch Kid Mode · Practice Questions · Study Sets · Curriculum ·
// Progress · Practice Areas · Settings · Subscription
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../domain/entities/child_entity.dart';
import '../../../domain/entities/study_set_entity.dart';
import '../../../domain/entities/progress_entity.dart';
import '../providers/parent_provider.dart';
import '../providers/insights_provider.dart';
import 'parent_widgets.dart';

const _back = 'M15 18l-6-6 6-6';
const _check = 'M5 12l4 4L19 7';
const _chevronDown = 'M6 9l6 6 6-6';
const _plus = 'M12 5v14M5 12h14';

Color _subjectTint(String s) => switch (s) {
      'Maths' => AppColours.blue,
      'English' => AppColours.purple,
      'Science' => AppColours.teal,
      'Spelling' => AppColours.amber,
      _ => AppColours.blue,
    };

String _subjectEmoji(String s) => switch (s) {
      'Maths' => '➗',
      'English' => '📖',
      'Science' => '🧪',
      'Spelling' => '✏️',
      _ => '📚',
    };

Widget _header(String title, VoidCallback onBack, {Widget? action}) => Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColours.line)),
      ),
      child: Row(
        children: [
          GestureDetector(onTap: onBack, child: appSvg(_back, size: 22, stroke: AppColours.blue, strokeWidth: 2)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColours.ink)),
          ),
          if (action != null) action,
        ],
      ),
    );

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColours.blue.withOpacity(0.10), AppColours.purple.withOpacity(0.15)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go(AppRoutes.parent),
                    icon: const Icon(Icons.close, color: AppColours.muted, size: 26),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColours.blue, AppColours.purple],
                            ),
                            boxShadow: [
                              BoxShadow(color: AppColours.purple.withOpacity(0.44), blurRadius: 20, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: const Center(child: Text('🎒', style: TextStyle(fontSize: 36))),
                        ),
                        const SizedBox(height: 18),
                        const Text('Ready to Learn?',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColours.ink)),
                        const SizedBox(height: 8),
                        const Text("Kid Mode only shows activities you've approved.",
                            textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColours.muted)),
                        const SizedBox(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('CHOOSE LEARNER',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.muted, letterSpacing: 0.4)),
                        ),
                        const SizedBox(height: 10),
                        childrenAsync.when(
                          data: (children) => Column(
                            children: children.asMap().entries.map<Widget>((e) {
                              final c = e.value;
                              final isSel = selected?.id == c.id;
                              return GestureDetector(
                                onTap: () => ref.read(selectedChildNotifierProvider.notifier).selectChild(c.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: isSel ? AppColours.blue : AppColours.line, width: 2),
                                    boxShadow: isSel
                                        ? [BoxShadow(color: AppColours.blue.withOpacity(0.22), blurRadius: 14, offset: const Offset(0, 6))]
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Avatar(emoji: c.avatar, size: 48, colour: childColour(e.key)),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(c.nickname,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.ink)),
                                            const SizedBox(height: 2),
                                            Consumer(builder: (_, ref, __) {
                                              final count = ref.watch(approvedSetCountProvider(c.id)).valueOrNull ?? 0;
                                              return Text('${c.yearGroup} · $count approved set${count == 1 ? '' : 's'}',
                                                  style: const TextStyle(fontSize: 13, color: AppColours.muted));
                                            }),
                                          ],
                                        ),
                                      ),
                                      if (isSel)
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(color: AppColours.blue, shape: BoxShape.circle),
                                          child: Center(child: appSvg(_check, size: 14, stroke: Colors.white, strokeWidth: 3)),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const SizedBox(),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColours.purple.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🛡', style: TextStyle(fontSize: 22)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No purchases, no external links, no chat. To return to Parent Mode, enter your PIN.',
                                  style: TextStyle(fontSize: 13, color: AppColours.ink2, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: PrimaryButton(
                    label: 'Start Kid Mode',
                    colour: AppColours.purple,
                    onPressed: () => context.go(AppRoutes.kid),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// sPQ · PRACTICE QUESTIONS
// ═══════════════════════════════════════════════════════

class PracticeQuestionsScreen extends StatefulWidget {
  const PracticeQuestionsScreen({super.key});
  @override
  State<PracticeQuestionsScreen> createState() => _PracticeQuestionsScreenState();
}

class _PracticeQuestionsScreenState extends State<PracticeQuestionsScreen> {
  int _level = 1;
  static const _levelLabels = ['Easier', 'Standard', 'Harder'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            _header('Practice Questions', () => context.go(AppRoutes.studySetReady)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColours.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Practice Questions',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.ink)),
                        const SizedBox(height: 4),
                        const Text('Generate a set from a scan to create printable questions.',
                            style: TextStyle(fontSize: 12, color: AppColours.muted)),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(3, (i) {
                            final on = _level == i;
                            return GestureDetector(
                              onTap: () => setState(() => _level = i),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: on ? AppColours.blue : Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: on ? AppColours.blue : AppColours.line, width: 1.5),
                                ),
                                child: Text(_levelLabels[i],
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: on ? Colors.white : AppColours.muted)),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const EmptyState(
                    emoji: '📝',
                    title: 'No questions yet',
                    message: 'Practice questions will appear here after you scan a worksheet and generate a set.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(16)),
                        child: const Center(
                          child: Text('🖨 Print', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColours.ink2)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: PrimaryButton(label: '⬇ Download PDF', onPressed: () {})),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// sSS · STUDY SETS  (shell route — no internal nav bar)
// ═══════════════════════════════════════════════════════

class StudySetsScreen extends ConsumerStatefulWidget {
  const StudySetsScreen({super.key});
  @override
  ConsumerState<StudySetsScreen> createState() => _StudySetsScreenState();
}

class _StudySetsScreenState extends ConsumerState<StudySetsScreen> {
  bool _mysets = true;

  @override
  Widget build(BuildContext context) {
    final setsAsync = ref.watch(studySetsStreamProvider);
    final childrenAsync = ref.watch(childrenStreamProvider);
    final child = ref.watch(selectedChildNotifierProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Study Sets',
                        style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColours.ink)),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.ocrReview),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: AppColours.blue, borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          appSvg(_plus, size: 15, stroke: Colors.white, strokeWidth: 2.5),
                          const SizedBox(width: 5),
                          const Text('New Scan',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          _TabBtn('📁 My Sets', _mysets, () => setState(() => _mysets = true)),
                          _TabBtn('📚 Curriculum', !_mysets, () => setState(() => _mysets = false)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    childrenAsync.when(
                      data: (children) => SizedBox(
                        height: 42,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: children.map<Widget>((c) {
                            final sel = child?.id == c.id;
                            return GestureDetector(
                              onTap: () => ref.read(selectedChildNotifierProvider.notifier).selectChild(c.id),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: sel ? AppColours.blue.withOpacity(0.12) : Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: sel ? AppColours.blue : AppColours.line, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Text(c.avatar, style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Text(c.nickname,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: sel ? AppColours.blue : AppColours.ink)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      loading: () => const SizedBox(height: 42),
                      error: (_, __) => const SizedBox(height: 42),
                    ),
                    const SizedBox(height: 12),
                    setsAsync.when(
                      data: (sets) => sets.isEmpty
                          ? const _EmptyStudySets()
                          : Column(children: sets.map((s) => _StudySetCard(set: s)).toList()),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
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

class _TabBtn extends StatelessWidget {
  const _TabBtn(this.label, this.active, this.onTap);
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)] : [],
            ),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: active ? AppColours.ink : AppColours.muted)),
            ),
          ),
        ),
      );
}

class _StudySetCard extends StatelessWidget {
  const _StudySetCard({required this.set});
  final StudySetEntity set;

  String _dateStr(DateTime dt) =>
      '${dt.day} ${const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][dt.month]}';

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColours.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconSquare(colour: _subjectTint(set.subject), size: 40, child: Text(_subjectEmoji(set.subject), style: const TextStyle(fontSize: 19))),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(set.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColours.ink)),
                ),
                StatusPill(set.status),
              ],
            ),
            const SizedBox(height: 6),
            Text('${set.subject} · ${_dateStr(set.createdAt)}',
                style: const TextStyle(fontSize: 12, color: AppColours.muted)),
            const SizedBox(height: 8),
            Row(
              children: [
                _Count('🃏', '${set.cardCount} cards'),
                const SizedBox(width: 12),
                _Count('🎯', '${set.questionCount}Q'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _ActionBtn('📖 Study', () {}),
                const SizedBox(width: 8),
                _ActionBtn('✨ Generate', () => context.go(AppRoutes.chooseOutput)),
                const SizedBox(width: 8),
                _ActionBtn('🖨 Print', () => context.go(AppRoutes.practiceQ)),
              ],
            ),
          ],
        ),
      );
}

class _Count extends StatelessWidget {
  const _Count(this.emoji, this.label);
  final String emoji, label;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.muted)),
        ],
      );
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(11)),
            child: Center(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.ink2)),
            ),
          ),
        ),
      );
}

class _EmptyStudySets extends StatelessWidget {
  const _EmptyStudySets();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColours.line)),
        child: const Column(
          children: [
            Text('🗂', style: TextStyle(fontSize: 48)),
            SizedBox(height: 10),
            Text('No study sets yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.ink)),
            SizedBox(height: 6),
            Text('Scan a worksheet to get started.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColours.muted)),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════
// sCT · CURRICULUM TOPIC
// ═══════════════════════════════════════════════════════

class CurriculumTopicScreen extends StatelessWidget {
  const CurriculumTopicScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(
              'Fractions',
              () => context.go(AppRoutes.studySets),
              action: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColours.blue, borderRadius: BorderRadius.circular(999)),
                  child: const Text('+ Assign',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      Pill('Maths', bg: AppColours.blueLight, fg: AppColours.blue),
                      Pill('Year 4', bg: AppColours.amberLight, fg: AppColours.amber),
                      Pill('Age 8–10', bg: AppColours.tealLight, fg: AppColours.teal),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColours.line)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Text('💡', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text('Parent Explanation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.ink)),
                        ]),
                        const SizedBox(height: 12),
                        const Text(
                          'A fraction shows part of a whole. The bottom number is the denominator — how many equal parts the whole is split into. The top number is the numerator — how many of those parts you have.\n\nTwo fractions are equivalent when they show the same amount — for example, ½ = 2/4 = 4/8.',
                          style: TextStyle(fontSize: 14, color: AppColours.ink2, height: 1.7),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColours.teal.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: const Border(left: BorderSide(color: AppColours.teal, width: 3)),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('HOW TO EXPLAIN AT HOME',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColours.teal, letterSpacing: 0.5)),
                              SizedBox(height: 4),
                              Text('Try cutting a pizza into equal pieces. Ask: "If I cut it into 4 pieces and you eat 2, what fraction did you eat?"',
                                  style: TextStyle(fontSize: 13, color: AppColours.ink2, height: 1.6)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColours.line)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Topics Covered', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.ink)),
                        SizedBox(height: 10),
                        _TopicRow('📝', 'What is a fraction?'),
                        _TopicRow('🔢', 'Numerator & denominator'),
                        _TopicRow('🔄', 'Equivalent fractions', isLast: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(child: PrimaryButton(label: '🃏 Study Now', onPressed: () => context.go(AppRoutes.flashcards))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.chooseOutput),
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(16)),
                        child: const Center(child: Text('✨ Generate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColours.ink2))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow(this.emoji, this.label, {this.isLast = false});
  final String emoji, label;
  final bool isLast;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColours.line))),
        child: Row(
          children: [
            IconSquare(colour: AppColours.blue, size: 32, radius: 9, child: Text(emoji, style: const TextStyle(fontSize: 16))),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.ink2))),
            const Icon(Icons.chevron_right, color: AppColours.muted),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════
// S22 · PARENT PROGRESS  (shell route — no internal nav bar)
// ═══════════════════════════════════════════════════════

class ParentProgressScreen extends ConsumerStatefulWidget {
  const ParentProgressScreen({super.key});
  @override
  ConsumerState<ParentProgressScreen> createState() => _ParentProgressState();
}

class _ParentProgressState extends ConsumerState<ParentProgressScreen> {
  bool _7days = true;

  static String _note(double pct) =>
      pct >= 80 ? 'Doing well' : pct >= 65 ? 'On track' : 'Needs practice';

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(selectedChildNotifierProvider).valueOrNull;
    final childrenAsync = ref.watch(childrenStreamProvider);
    final summary = ref.watch(childProgressProvider).valueOrNull;

    final List<ProgressEntity> quizzes = summary == null
        ? const []
        : summary.sessions.where((s) => s.activityType == 'quiz').toList();
    final flashcardsAnswered = summary == null
        ? 0
        : summary.sessions
            .where((s) => s.activityType == 'flashcard')
            .fold<int>(0, (a, s) => a + s.total);
    final avgQuiz = quizzes.isEmpty
        ? 0
        : (quizzes.map((q) => q.percentage).reduce((a, b) => a + b) / quizzes.length).round();

    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppColours.line))),
              child: Row(
                children: [
                  GestureDetector(onTap: () => context.go(AppRoutes.parent), child: appSvg(_back, size: 22, stroke: AppColours.blue, strokeWidth: 2)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Progress', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColours.ink)),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _7days = !_7days),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColours.line),
                      ),
                      child: Row(
                        children: [
                          Text(_7days ? '7 days' : '30 days',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.ink)),
                          const SizedBox(width: 4),
                          appSvg(_chevronDown, size: 14, stroke: AppColours.muted, strokeWidth: 2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    childrenAsync.when(
                      data: (children) => SizedBox(
                        height: 52,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: children.map<Widget>((c) {
                            final sel = child?.id == c.id;
                            return GestureDetector(
                              onTap: () => ref.read(selectedChildNotifierProvider.notifier).selectChild(c.id),
                              child: Container(
                                margin: const EdgeInsets.only(right: 9),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel ? AppColours.blue.withOpacity(0.12) : Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: sel ? AppColours.blue : AppColours.line, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Text(c.avatar, style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text(c.nickname,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: sel ? AppColours.blue : AppColours.ink)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      loading: () => const SizedBox(height: 52),
                      error: (_, __) => const SizedBox(height: 52),
                    ),
                    const SizedBox(height: 14),
                    if (summary == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (summary.isEmpty)
                      const EmptyState(
                        emoji: '📊',
                        title: 'No progress yet',
                        message: 'Learning progress will appear here once your child starts studying.',
                      )
                    else ...[
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.7,
                        children: [
                          _StatTile('🃏', 'Flashcards', '$flashcardsAnswered', '', AppColours.muted),
                          _StatTile('🎯', 'Avg quiz', '$avgQuiz%', '', AppColours.muted),
                          _StatTile('⭐', 'Stars', '${child?.stars ?? 0}', '', AppColours.muted),
                          _StatTile('🔥', 'Streak', '${child?.streak ?? 0} days', '', AppColours.muted),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColours.line)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Scores by Subject', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.ink)),
                            const SizedBox(height: 14),
                            if (summary.subjectScores.isEmpty)
                              const Text('No quiz scores yet.',
                                  style: TextStyle(fontSize: 13, color: AppColours.muted))
                            else
                              ...summary.subjectScores.entries.map((e) {
                                final colour = _subjectTint(e.key);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${_subjectEmoji(e.key)} ${e.key}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.ink2)),
                                          Text('${e.value.round()}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colour)),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      ScoreProgressBar(value: e.value / 100, colour: colour),
                                      const SizedBox(height: 4),
                                      Text(_note(e.value), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colour)),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
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

class _StatTile extends StatelessWidget {
  const _StatTile(this.emoji, this.label, this.value, this.change, this.changeColour);
  final String emoji, label, value, change;
  final Color changeColour;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColours.line)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconSquare(colour: AppColours.blue, size: 30, radius: 9, child: Text(emoji, style: const TextStyle(fontSize: 15))),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.muted)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColours.ink)),
            Text(change, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: changeColour)),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════
// S23 · PRACTICE AREAS
// ═══════════════════════════════════════════════════════

class PracticeAreasScreen extends ConsumerWidget {
  const PracticeAreasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(selectedChildNotifierProvider).valueOrNull;
    final summary = ref.watch(childProgressProvider).valueOrNull;
    final weakest = summary == null
        ? const <MapEntry<String, double>>[]
        : (summary.subjectScores.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value)));

    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            _header('Practice Areas', () => context.go(AppRoutes.progress)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                children: [
                  Row(
                    children: [
                      Avatar(emoji: child?.avatar ?? '🚀', size: 32, colour: AppColours.blue),
                      const SizedBox(width: 10),
                      Text('${child?.nickname ?? 'Your child'} · ${child?.yearGroup ?? ''}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.ink)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (summary == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 30, bottom: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (weakest.isEmpty) ...[
                    const Text('Weak areas will appear here once your child completes some quizzes.',
                        style: TextStyle(fontSize: 13, color: AppColours.muted)),
                    const SizedBox(height: 16),
                  ] else ...[
                    const Text('These topics could use a bit more practice.',
                        style: TextStyle(fontSize: 13, color: AppColours.muted)),
                    const SizedBox(height: 16),
                    ...weakest.map((e) {
                      final colour = _subjectTint(e.key);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColours.line)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconSquare(colour: colour, size: 36, radius: 10, child: Text(_subjectEmoji(e.key), style: const TextStyle(fontSize: 18))),
                                const SizedBox(width: 10),
                                Expanded(child: Text(e.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.ink))),
                                Text('${e.value.round()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: colour)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _ActionBtn('✨ Create Set', () => context.go(AppRoutes.chooseOutput)),
                                const SizedBox(width: 8),
                                _ActionBtn('📚 Curriculum', () => context.go(AppRoutes.curriculum)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColours.green.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColours.green.withOpacity(0.33)),
                    ),
                    child: const Row(
                      children: [
                        Text('💡', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Short, focused sets on one weak topic work better than long mixed ones.',
                              style: TextStyle(fontSize: 13, color: AppColours.ink2, height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryButton(
                label: '✨ Create Practice Set for All',
                colour: AppColours.purple,
                onPressed: () => context.go(AppRoutes.chooseOutput),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// S24 · SETTINGS  (shell route — no internal nav bar)
// ═══════════════════════════════════════════════════════

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _requirePin = true;

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(childrenStreamProvider);
    final setsCount = ref.watch(studySetsStreamProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppColours.line))),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('Settings', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColours.ink)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  // Premium banner
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.subscription),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(colors: [AppColours.amber, Color(0xFFF97316)]),
                        boxShadow: [BoxShadow(color: AppColours.amber.withOpacity(0.44), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: const Row(
                        children: [
                          Text('✨', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Upgrade to Premium', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                                SizedBox(height: 2),
                                Text('Unlimited scans, curriculum & progress reports', style: TextStyle(fontSize: 12, color: Colors.white)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const _SettingLabel('CHILDREN'),
                  _SettingCard(
                    children: [
                      ...childrenAsync.when(
                        data: (children) => children
                            .where((c) => c.nickname.isNotEmpty && !c.nickname.startsWith('['))
                            .map<Widget>((c) => _SettingRow(c.avatar, c.nickname,
                                '${c.yearGroup} · ${c.subjects.join(' · ')}', () {}))
                            .toList(),
                        loading: () => const <Widget>[],
                        error: (_, __) => const <Widget>[],
                      ),
                      _SettingRowAdd(() {}),
                    ],
                  ),
                  const _SettingLabel('SECURITY'),
                  _SettingCard(
                    children: [
                      _SettingRow('🔒', 'Change Parent PIN', null, () {}),
                      _SettingRowToggle('🛡', 'Require PIN for Parent Mode', _requirePin, () => setState(() => _requirePin = !_requirePin)),
                    ],
                  ),
                  const _SettingLabel('DATA & PRIVACY'),
                  _SettingCard(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                        child: Text(
                          'Worksheet images and study sets are saved on this device. When AI features are used, extracted text may be processed to create flashcards, quizzes and explanations.',
                          style: TextStyle(fontSize: 13, color: AppColours.muted, height: 1.6),
                        ),
                      ),
                      _SettingRow('📁', 'Manage study sets', '$setsCount saved', () {}),
                      _SettingRowDanger('⚠️', 'Clear all local data', () {}),
                    ],
                  ),
                  const _SettingLabel('APP'),
                  const _SettingCard(
                    children: [
                      _SettingRow('ℹ️', 'Version 1.0.0', null, _noop),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text('Made for curious kids · StudySnap',
                        style: TextStyle(fontSize: 12, color: AppColours.muted)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _noop() {}

class _SettingLabel extends StatelessWidget {
  const _SettingLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.muted, letterSpacing: 0.4)),
      );
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColours.line)),
        child: Column(children: children),
      );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow(this.icon, this.label, this.sub, this.onTap);
  final String icon, label;
  final String? sub;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColours.line))),
          child: Row(
            children: [
              IconSquare(colour: AppColours.blue, size: 34, radius: 10, child: Text(icon, style: const TextStyle(fontSize: 17))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.ink)),
                    if (sub != null)
                      Text(sub!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColours.muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColours.muted),
            ],
          ),
        ),
      );
}

class _SettingRowAdd extends StatelessWidget {
  const _SettingRowAdd(this.onTap);
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: AppColours.blue.withOpacity(0.14), borderRadius: BorderRadius.circular(10)),
                child: const Center(child: Icon(Icons.add, color: AppColours.blue, size: 20)),
              ),
              const SizedBox(width: 12),
              const Text('Add child', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.blue)),
              const Spacer(),
              const Icon(Icons.chevron_right, color: AppColours.blue),
            ],
          ),
        ),
      );
}

class _SettingRowToggle extends StatelessWidget {
  const _SettingRowToggle(this.icon, this.label, this.value, this.onToggle);
  final String icon, label;
  final bool value;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            IconSquare(colour: AppColours.blue, size: 34, radius: 10, child: Text(icon, style: const TextStyle(fontSize: 17))),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.ink))),
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 28,
                decoration: BoxDecoration(color: value ? AppColours.blue : AppColours.line, borderRadius: BorderRadius.circular(99)),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _SettingRowDanger extends StatelessWidget {
  const _SettingRowDanger(this.icon, this.label, this.onTap);
  final String icon, label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: AppColours.red.withOpacity(0.14), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 17))),
              ),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColours.red)),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════
// S25 · SUBSCRIPTION  (dark)
// ═══════════════════════════════════════════════════════

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
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F172A);
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(center: Alignment(-0.6, -0.7), radius: 0.8, colors: [Color(0x33A78BFA), Color(0x000F172A)]),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(center: Alignment(0.7, 0.5), radius: 0.9, colors: [Color(0x263B82F6), Color(0x000F172A)]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.go(AppRoutes.settings),
                        icon: const Icon(Icons.close, color: Colors.white70, size: 24),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.settings),
                        child: const Text('Restore', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: const LinearGradient(colors: [AppColours.amber, Color(0xFFF97316)]),
                            boxShadow: [BoxShadow(color: AppColours.amber.withOpacity(0.88), blurRadius: 28, offset: const Offset(0, 8))],
                          ),
                          child: const Center(child: Text('✨', style: TextStyle(fontSize: 36))),
                        ),
                        const SizedBox(height: 18),
                        const Text('Unlock More Learning',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('Unlimited worksheets, curriculum access, and detailed progress reports.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.7), height: 1.5)),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Column(
                            children: _features.asMap().entries.map((e) {
                              final last = e.key == _features.length - 1;
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  border: last ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(child: Text(e.value.$1, style: const TextStyle(fontSize: 15))),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(e.value.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                    ),
                                    appSvg(_check, size: 16, stroke: AppColours.green, strokeWidth: 3),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Monthly (glass)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.10)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Monthly', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                                  Text('Cancel anytime', style: TextStyle(fontSize: 12, color: Colors.white70)),
                                ],
                              ),
                              Text('£4.99', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Yearly (highlight)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppColours.purple, AppColours.blue],
                                ),
                                border: Border.all(color: AppColours.purple, width: 2),
                                boxShadow: [BoxShadow(color: AppColours.purple.withOpacity(0.44), blurRadius: 20, offset: const Offset(0, 8))],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Yearly', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                                      Text('Save 33% · 2 months free', style: TextStyle(fontSize: 12, color: Colors.white)),
                                    ],
                                  ),
                                  Text('£39.99', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                                ],
                              ),
                            ),
                            Positioned(
                              top: -10,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(color: AppColours.amber, borderRadius: BorderRadius.circular(999)),
                                child: const Text('BEST VALUE',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.settings),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.20), blurRadius: 20)],
                          ),
                          child: const Center(
                            child: Text('Start 7-Day Free Trial',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.settings),
                        child: const Text('Continue with Free Plan',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
