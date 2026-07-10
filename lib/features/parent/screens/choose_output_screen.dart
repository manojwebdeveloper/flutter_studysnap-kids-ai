// ═══════════════════════════════════════════════════════
// S12 CHOOSE OUTPUT · S13 READY · S14 EDIT CARDS · S15 EDIT QUIZ
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/parent_provider.dart';
import 'parent_widgets.dart';

const _back = 'M15 18l-6-6 6-6';
const _check = 'M5 12l4 4L19 7';
const _plus = 'M12 5v14M5 12h14';
const _editIcon =
    'M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7M18.5 2.5a2.12 2.12 0 013 3L12 15l-4 1 1-4 9.5-9.5z';
const _trashIcon =
    'M3 6h18M8 6V4a2 2 0 012-2h4a2 2 0 012 2v2m3 0v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6';

Widget _header(String title, VoidCallback onBack, {Widget? action}) => Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColours.line)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: appSvg(_back, size: 22, stroke: AppColours.blue, strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColours.ink)),
          ),
          if (action != null) action,
        ],
      ),
    );

class _DashedAdd extends StatelessWidget {
  const _DashedAdd(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 56,
          decoration: BoxDecoration(
            color: AppColours.subtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColours.line, width: 1.5),
          ),
          child: Center(
            child: Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.blue)),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════
// S12 · CHOOSE OUTPUT
// ═══════════════════════════════════════════════════════

class ChooseOutputScreen extends ConsumerStatefulWidget {
  const ChooseOutputScreen({super.key});
  @override
  ConsumerState<ChooseOutputScreen> createState() => _ChooseOutputScreenState();
}

class _ChooseOutputScreenState extends ConsumerState<ChooseOutputScreen> {
  // Local UI-only selections (design controls; not part of the generation API).
  String _difficulty = 'Standard';
  int _practiceCount = 20;

  static const _outputs = [
    ('flashcards', '🃏', 'Flashcards', 'Front/back study cards with explanations', AppColours.blue),
    ('quiz', '🎯', 'Quiz', 'Multiple choice & true/false questions', AppColours.purple),
    ('explanation', '💡', 'Simple Explanation', 'Topic explained in kid-friendly words', AppColours.teal),
    ('practiceQs', '✏️', 'Practice Questions', 'Printable worksheets with mark scheme', AppColours.amber),
    ('parentGuide', '👪', 'Parent Help Guide', 'How to explain this topic at home', AppColours.muted),
  ];

  static const _ageLevels = ['Reception', 'Year 1–2', 'Year 3–4', 'Year 5–6', 'Year 7+'];
  static const _difficulties = ['Standard', 'Easier', 'Harder', 'Mixed'];
  static const _counts = [10, 20, 30, 50];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chooseOutputNotifierProvider);
    final notifier = ref.read(chooseOutputNotifierProvider.notifier);
    final ocrState = ref.watch(ocrReviewNotifierProvider);
    final child = ref.watch(selectedChildNotifierProvider).valueOrNull;

    bool isOn(String key) => switch (key) {
          'flashcards' => state.flashcards,
          'quiz' => state.quiz,
          'explanation' => state.explanation,
          'practiceQs' => state.practiceQs,
          'parentGuide' => state.parentGuide,
          _ => false,
        };
    final anyOn = _outputs.any((o) => isOn(o.$1));

    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            _header('Create Study Set', () => context.go(AppRoutes.ocrReview)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('What would you like to create?',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColours.ink)),
                    const SizedBox(height: 4),
                    const Text('Choose activities. Your child only sees content you approve.',
                        style: TextStyle(fontSize: 13, color: AppColours.muted, height: 1.5)),
                    const SizedBox(height: 14),
                    ..._outputs.map((o) {
                      final on = isOn(o.$1);
                      final tint = o.$5;
                      return GestureDetector(
                        onTap: () => notifier.toggle(o.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: on ? tint : AppColours.line, width: on ? 2 : 1.5),
                            boxShadow: on
                                ? [BoxShadow(color: tint.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 4))]
                                : null,
                          ),
                          child: Row(
                            children: [
                              IconSquare(colour: tint, child: Text(o.$2, style: const TextStyle(fontSize: 20))),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(o.$3,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.ink)),
                                    const SizedBox(height: 2),
                                    Text(o.$4, style: const TextStyle(fontSize: 12, color: AppColours.muted)),
                                  ],
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: on ? tint : Colors.white,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(color: on ? tint : AppColours.line, width: 2),
                                ),
                                child: on ? Center(child: appSvg(_check, size: 14, stroke: Colors.white, strokeWidth: 3)) : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 6),
                    // Age level
                    _CardBox(
                      label: 'AGE LEVEL',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._ageLevels.map((lvl) {
                            final sel = state.ageLevel == lvl;
                            return _Chip(lvl, sel, AppColours.blue, () => notifier.setAgeLevel(lvl));
                          }),
                          _Chip('GCSE 🔒', false, AppColours.muted, null),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Difficulty
                    _CardBox(
                      label: 'DIFFICULTY',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _difficulties
                            .map((d) => _Chip(d, _difficulty == d, AppColours.purple, () => setState(() => _difficulty = d)))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Practice question count
                    _CardBox(
                      label: 'PRACTICE QUESTIONS',
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: AppColours.subtle,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: _counts.map((n) {
                            final on = _practiceCount == n;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _practiceCount = n),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  color: on ? AppColours.amber : Colors.transparent,
                                  child: Center(
                                    child: Text('$n',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: on ? Colors.white : AppColours.muted)),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom CTA
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColours.line)),
              ),
              child: PrimaryButton(
                label: '✨ Generate Study Set',
                isLoading: state.isGenerating,
                onPressed: (!anyOn || state.isGenerating)
                    ? null
                    : () async {
                        final ok = await notifier.generate(
                          ocrState.extractedText,
                          ocrState.subject,
                          child?.yearGroup ?? 'Year 4',
                        );
                        if (ok && context.mounted) context.go(AppRoutes.studySetReady);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  const _CardBox({required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColours.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.muted, letterSpacing: 0.4)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.selected, this.tint, this.onTap);
  final String label;
  final bool selected;
  final Color tint;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? tint.withOpacity(0.14) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? tint : AppColours.line, width: 1.5),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? tint : AppColours.ink)),
        ),
      );
}

// ═══════════════════════════════════════════════════════
// S13 · STUDY SET READY
// ═══════════════════════════════════════════════════════

class StudySetReadyScreen extends ConsumerWidget {
  const StudySetReadyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(studySetsStreamProvider).valueOrNull;
    final latestSet = (sets == null || sets.isEmpty) ? null : sets.first;

    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            _header('Study Set Ready', () => context.go(AppRoutes.chooseOutput)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Green banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColours.green.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColours.green.withOpacity(0.44), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(color: AppColours.green, shape: BoxShape.circle),
                            child: Center(child: appSvg(_check, size: 18, stroke: Colors.white, strokeWidth: 3)),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Saved to Study Sets',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.green)),
                                Text('Generated · review before approving',
                                    style: TextStyle(fontSize: 12, color: AppColours.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Topic card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColours.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOPIC DETECTED',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColours.muted, letterSpacing: 0.4)),
                          const SizedBox(height: 4),
                          Text(latestSet?.title ?? 'Equivalent Fractions',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColours.ink)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              Pill(latestSet?.subject ?? 'Maths', bg: AppColours.blueLight, fg: AppColours.blue),
                              Pill(latestSet?.yearGroup ?? 'Year 4', bg: AppColours.blueLight, fg: AppColours.blue),
                              Pill('Age 8–10', bg: AppColours.amberLight, fg: AppColours.amber),
                              Pill('Standard', bg: AppColours.subtle, fg: AppColours.muted),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _OutputRow('🃏', AppColours.blue, 'Flashcards', '12 front/back cards with explanations',
                        '12', 'Edit cards →', () => context.go(AppRoutes.editCards)),
                    _OutputRow('🎯', AppColours.purple, 'Quiz', '8 multiple-choice & true/false questions',
                        '8', 'Edit quiz →', () => context.go(AppRoutes.editQuiz)),
                    _OutputRow('💡', AppColours.teal, 'Simple Explanation', '1 page · age 8–10 language',
                        '1', 'View →', () {}),
                    _OutputRow('✏️', AppColours.amber, 'Practice Questions', '20 questions · printable PDF',
                        '20', 'View & Print →', () => context.go(AppRoutes.practiceQ)),
                    _OutputRow('👪', AppColours.muted, 'Parent Help Guide', 'Tips for explaining at home',
                        '1', 'View →', () {}),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: _SecondaryBtn('🔄 Regenerate', () {})),
                        const SizedBox(width: 10),
                        Expanded(child: _SecondaryBtn('➕ Generate More', () {})),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: PrimaryButton(
                label: '✓ Approve for Kid Mode',
                colour: AppColours.green,
                onPressed: () async {
                  if (latestSet != null) {
                    await ref.read(studySetsRepositoryProvider).approve(latestSet.id);
                  }
                  if (context.mounted) context.go(AppRoutes.studySets);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutputRow extends StatelessWidget {
  const _OutputRow(this.emoji, this.tint, this.title, this.sub, this.count, this.link, this.onLink);
  final String emoji, title, sub, count, link;
  final Color tint;
  final VoidCallback onLink;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColours.line),
        ),
        child: Row(
          children: [
            IconSquare(colour: tint, child: Text(emoji, style: const TextStyle(fontSize: 20))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.ink)),
                      ),
                      const SizedBox(width: 6),
                      Pill(count, bg: tint.withOpacity(0.14), fg: tint),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(fontSize: 12, color: AppColours.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onLink,
              child: Text(link, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tint)),
            ),
          ],
        ),
      );
}

class _SecondaryBtn extends StatelessWidget {
  const _SecondaryBtn(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColours.line, width: 1.5),
          ),
          child: Center(
            child: Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.ink)),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════
// S14 · EDIT FLASHCARDS
// ═══════════════════════════════════════════════════════

class EditFlashcardsScreen extends ConsumerWidget {
  const EditFlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = [
      ('What is a fraction?', 'A fraction shows part of a whole.', 'Easy'),
      ('What is a numerator?', 'The top number — it shows how many parts you have.', 'Easy'),
      ('What is a denominator?', 'The bottom number — how many parts the whole is split into.', 'Med'),
      ('Are 1/2 and 2/4 equivalent?', 'Yes — both equal one half.', 'Med'),
    ];

    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(
              'Edit Flashcards',
              () => context.go(AppRoutes.studySetReady),
              action: GestureDetector(
                onTap: () => context.go(AppRoutes.studySetReady),
                child: const Text('Save',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.blue)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('4 of 12 cards · drag to reorder',
                    style: TextStyle(fontSize: 13, color: AppColours.muted)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                children: [
                  ...cards.asMap().entries.map((e) => _FlashcardItem(
                        num: e.key + 1,
                        question: e.value.$1,
                        answer: e.value.$2,
                        difficulty: e.value.$3,
                      )),
                  _DashedAdd('+ Add card', () {}),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryButton(label: 'Save Flashcards', onPressed: () => context.go(AppRoutes.studySetReady)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DragDots extends StatelessWidget {
  const _DragDots();
  @override
  Widget build(BuildContext context) {
    Widget dot() => Container(
          width: 3,
          height: 3,
          margin: const EdgeInsets.all(1),
          decoration: const BoxDecoration(color: AppColours.muted, shape: BoxShape.circle),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (_) => Row(mainAxisSize: MainAxisSize.min, children: [dot(), dot()])),
    );
  }
}

class _FlashcardItem extends StatelessWidget {
  const _FlashcardItem({required this.num, required this.question, required this.answer, required this.difficulty});
  final int num;
  final String question, answer, difficulty;

  @override
  Widget build(BuildContext context) {
    final diffColour = switch (difficulty) {
      'Easy' => AppColours.green,
      'Med' => AppColours.amber,
      _ => AppColours.red,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _DragDots(),
              const SizedBox(width: 8),
              Text('CARD $num',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColours.muted)),
              const Spacer(),
              Pill(difficulty, bg: diffColour.withOpacity(0.14), fg: diffColour),
              const SizedBox(width: 10),
              appSvg(_editIcon, size: 18, stroke: AppColours.muted, strokeWidth: 2),
              const SizedBox(width: 10),
              appSvg(_trashIcon, size: 18, stroke: AppColours.red, strokeWidth: 2),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(12)),
            child: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.ink)),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColours.blue.withOpacity(0.13),
              borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: AppColours.blue, width: 3)),
            ),
            child: Text(answer, style: const TextStyle(fontSize: 13, color: AppColours.ink2, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// S15 · EDIT QUIZ
// ═══════════════════════════════════════════════════════

class EditQuizScreen extends ConsumerWidget {
  const EditQuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(
              'Edit Quiz',
              () => context.go(AppRoutes.studySetReady),
              action: GestureDetector(
                onTap: () => context.go(AppRoutes.studySetReady),
                child: const Text('Save',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.purple)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('3 of 8 questions · Multiple choice & true/false',
                    style: TextStyle(fontSize: 13, color: AppColours.muted)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                children: [
                  _QuizItem(num: 1, question: 'What is ½ of 10?', options: const ['2', '5', '10', '20'], correct: 1,
                      explanation: '½ of 10 means splitting 10 into 2 equal parts and taking one — that\'s 5.'),
                  _QuizItem(num: 2, question: 'Are 1/2 and 2/4 equivalent fractions?', options: const ['True', 'False'], correct: 0,
                      explanation: 'Both fractions equal one half — they look different but have the same value.'),
                  _QuizItem(num: 3, question: 'The bottom number of a fraction is called the…',
                      options: const ['Numerator', 'Denominator', 'Equator', 'Divisor'], correct: 1,
                      explanation: 'The denominator names the parts the whole is split into.'),
                  _DashedAdd('+ Add question', () {}),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryButton(
                  label: 'Save Quiz', colour: AppColours.purple, onPressed: () => context.go(AppRoutes.studySetReady)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizItem extends StatelessWidget {
  const _QuizItem({required this.num, required this.question, required this.options, required this.correct, required this.explanation});
  final int num, correct;
  final String question, explanation;
  final List<String> options;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColours.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColours.purple.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('$num',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.purple)),
                  ),
                ),
                const SizedBox(width: 8),
                Pill('Multiple choice', bg: AppColours.purple.withOpacity(0.14), fg: AppColours.purple),
                const Spacer(),
                appSvg(_editIcon, size: 18, stroke: AppColours.muted, strokeWidth: 2),
              ],
            ),
            const SizedBox(height: 10),
            Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.ink)),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: options.asMap().entries.map((e) {
                final ok = e.key == correct;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ok ? AppColours.green.withOpacity(0.15) : AppColours.subtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ok ? AppColours.green : Colors.transparent, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      if (ok) ...[
                        appSvg(_check, size: 14, stroke: AppColours.green, strokeWidth: 3),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(e.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ok ? AppColours.green : AppColours.ink)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(border: Border(left: BorderSide(color: AppColours.line, width: 2))),
              child: Text(explanation,
                  style: const TextStyle(fontSize: 12, color: AppColours.muted, fontStyle: FontStyle.italic, height: 1.5)),
            ),
          ],
        ),
      );
}
