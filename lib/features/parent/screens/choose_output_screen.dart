// ═══════════════════════════════════════════════════════
// S12 · CHOOSE OUTPUT SCREEN
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/parent_provider.dart';

class ChooseOutputScreen extends ConsumerWidget {
  const ChooseOutputScreen({super.key});

  static const _outputs = [
    _OutputOption('flashcards', '🃏', 'Flashcards', 'Front/back study cards with explanations',
        AppColours.blueLight, AppColours.blue),
    _OutputOption('quiz', '🎯', 'Quiz', 'Multiple choice & true/false questions',
        AppColours.purpleLight, AppColours.purple),
    _OutputOption('explanation', '💡', 'Simple Explanation', 'Topic explained in kid-friendly words',
        AppColours.tealLight, AppColours.teal),
    _OutputOption('practiceQs', '✏️', 'Practice Questions', 'Printable worksheets with mark scheme',
        AppColours.amberLight, AppColours.amber),
    _OutputOption('parentGuide', '👪', 'Parent Help Guide', 'How to explain this topic at home',
        AppColours.subtle, AppColours.textMuted),
  ];

  static const _ageLevels = ['Reception', 'Year 1–2', 'Year 3–4', 'Year 5–6', 'Year 7+'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(chooseOutputNotifierProvider);
    final notifier = ref.read(chooseOutputNotifierProvider.notifier);
    final ocrState = ref.watch(ocrReviewNotifierProvider);
    final child    = ref.watch(selectedChildNotifierProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColours.bg,
      appBar: AppBar(backgroundColor: AppColours.bg, elevation: 0,
        leading: GestureDetector(onTap: () => context.go(AppRoutes.ocrReview),
          child: const Row(children: [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios, color: AppColours.blue, size: 20),
            Text('Create Study Set', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.textDark)),
          ]))),
      body: SafeArea(child: Column(children: [
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('What would you like to create?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColours.textDark)),
            const SizedBox(height: 6),
            const Text('Choose activities. Your child only sees content you approve.',
              style: AppTextStyles.bodySmall),
            const SizedBox(height: 18),

            // Output options
            ..._outputs.map((opt) {
              final isOn = switch (opt.key) {
                'flashcards'  => state.flashcards,
                'quiz'        => state.quiz,
                'explanation' => state.explanation,
                'practiceQs'  => state.practiceQs,
                'parentGuide' => state.parentGuide,
                _             => false,
              };
              return GestureDetector(
                onTap: () => notifier.toggle(opt.key),
                child: AnimatedContainer(duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isOn ? opt.colour : AppColours.line, width: 2)),
                  child: Row(children: [
                    Container(width: 42, height: 42, decoration: BoxDecoration(
                      color: opt.bg, borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(opt.emoji, style: const TextStyle(fontSize: 20)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(opt.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textDark)),
                      const SizedBox(height: 2),
                      Text(opt.subtitle, style: const TextStyle(fontSize: 12, color: AppColours.textMuted)),
                    ])),
                    AnimatedContainer(duration: const Duration(milliseconds: 180),
                      width: 24, height: 24, decoration: BoxDecoration(
                        color: isOn ? opt.colour : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: isOn ? opt.colour : AppColours.line, width: 2)),
                      child: isOn ? const Icon(Icons.check, color: Colors.white, size: 14) : null),
                  ])),
              );
            }),

            const SectionLabel('AGE LEVEL'),
            Wrap(spacing: 8, runSpacing: 8, children: _ageLevels.map((lvl) {
              final sel = state.ageLevel == lvl;
              return GestureDetector(
                onTap: () => notifier.setAgeLevel(lvl),
                child: AnimatedContainer(duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColours.blueLight : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: sel ? AppColours.blue : AppColours.line, width: 1.5)),
                  child: Text(lvl, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: sel ? AppColours.blue : AppColours.textInk))),
              );
            }).toList()),
            const SizedBox(height: 20),
          ]),
        )),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: PrimaryButton(
            label: '✨ Generate Study Set',
            isLoading: state.isGenerating,
            onPressed: state.isGenerating ? null : () async {
              final ok = await notifier.generate(
                ocrState.extractedText, ocrState.subject,
                child?.yearGroup ?? 'Year 4',
              );
              if (ok && context.mounted) context.go(AppRoutes.studySetReady);
            },
          )),
      ])),
    );
  }
}

class _OutputOption {
  const _OutputOption(this.key, this.emoji, this.title, this.subtitle, this.bg, this.colour);
  final String key, emoji, title, subtitle;
  final Color bg, colour;
}

// ═══════════════════════════════════════════════════════
// S13 · STUDY SET READY SCREEN
// ═══════════════════════════════════════════════════════

class StudySetReadyScreen extends ConsumerWidget {
  const StudySetReadyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(studySetsStreamProvider);
    final latestSet = setsAsync.valueOrNull?.firstOrNull;

    return Scaffold(
      backgroundColor: AppColours.bg,
      appBar: AppBar(backgroundColor: AppColours.bg, elevation: 0,
        leading: GestureDetector(onTap: () => context.go(AppRoutes.chooseOutput),
          child: const Row(children: [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios, color: AppColours.blue, size: 20),
            Text('Study Set Ready', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.textDark)),
          ]))),
      body: SafeArea(child: Column(children: [
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Banner
            Container(width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColours.greenLight, borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Saved to Study Sets', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.green)),
                SizedBox(height: 2),
                Text('Generated in 6s · review before approving',
                  style: TextStyle(fontSize: 12, color: AppColours.textMuted)),
              ])),
            const SizedBox(height: 16),

            // Topic
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: AppColours.blueLight, borderRadius: BorderRadius.circular(7)),
                child: const Text('Maths', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.blue))),
            ]),
            const SizedBox(height: 8),
            Text(latestSet?.title ?? 'Equivalent Fractions',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColours.textDark, letterSpacing: -.3)),
            const SizedBox(height: 6),
            Wrap(spacing: 7, children: [
              _tag(latestSet?.yearGroup ?? 'Year 4', AppColours.blueLight, AppColours.blue),
              _tag('Age 8–10', AppColours.amberLight, AppColours.amber),
              _tag('Standard', AppColours.subtle, AppColours.textMuted),
            ]),
            const SizedBox(height: 16),

            // Output rows
            AppCard(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(children: [
                _OutputRow('🃏', AppColours.blueLight, 'Flashcards', '12 front/back cards with explanations',
                  '12', AppColours.blue, 'Edit cards →', () => context.go(AppRoutes.editCards)),
                _OutputRow('🎯', AppColours.purpleLight, 'Quiz', '8 multiple-choice & true/false questions',
                  '8', AppColours.purple, 'Edit quiz →', () => context.go(AppRoutes.editQuiz)),
                _OutputRow('💡', AppColours.tealLight, 'Simple Explanation', '1 page · age 8–10 language',
                  '1', AppColours.teal, 'View →', () {}),
                _OutputRow('✏️', AppColours.amberLight, 'Practice Questions', '20 questions · printable PDF',
                  '20', AppColours.amber, 'View & Print →', () => context.go(AppRoutes.practiceQ)),
                _OutputRow('👪', AppColours.subtle, 'Parent Help Guide', 'Tips for explaining at home',
                  '1', AppColours.textMuted, 'View →', () {}, isLast: true),
              ])),
            const SizedBox(height: 20),
          ]),
        )),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: PrimaryButton(
            label: '✓ Approve for Kid Mode',
            colour: AppColours.green,
            onPressed: () async {
              if (latestSet != null) {
                await ref.read(studySetsRepositoryProvider).approve(latestSet.id);
              }
              if (context.mounted) context.go(AppRoutes.studySets);
            },
          )),
      ])),
    );
  }

  Widget _tag(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
    child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)));

  Widget _OutputRow(String emoji, Color bg, String title, String sub,
      String count, Color countColour, String link, VoidCallback onLink, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColours.line))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 19)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textDark)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 12, color: AppColours.textMuted)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(count, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: countColour)),
          GestureDetector(onTap: onLink,
            child: Text(link, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: countColour))),
        ]),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════
// S14 · EDIT FLASHCARDS SCREEN
// ═══════════════════════════════════════════════════════

class EditFlashcardsScreen extends ConsumerWidget {
  const EditFlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In production, load from DB. Showing sample data.
    final cards = [
      ('What is a fraction?', 'A fraction shows part of a whole.', 'Easy'),
      ('What is a numerator?', 'The top number — it shows how many parts you have.', 'Easy'),
      ('What is a denominator?', 'The bottom number — how many parts the whole is split into.', 'Med'),
      ('Are 1/2 and 2/4 equivalent?', 'Yes — both equal one half.', 'Med'),
    ];

    return Scaffold(
      backgroundColor: AppColours.bg,
      appBar: AppBar(backgroundColor: AppColours.bg, elevation: 0,
        leading: GestureDetector(onTap: () => context.go(AppRoutes.studySetReady),
          child: const Row(children: [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios, color: AppColours.blue, size: 20),
            Text('Edit Flashcards', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.textDark)),
          ])),
        actions: [
          TextButton(onPressed: () => context.go(AppRoutes.studySetReady),
            child: const Text('Save', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.blue))),
        ]),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text('${cards.length} of 12 cards · drag to reorder',
            style: const TextStyle(fontSize: 13, color: AppColours.textMuted))),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            ...cards.asMap().entries.map((e) => _FCEditCard(
              num: e.key + 1, question: e.value.$1,
              answer: e.value.$2, difficulty: e.value.$3)),
            // Add card button
            GestureDetector(onTap: () {},
              child: Container(margin: const EdgeInsets.only(bottom: 10), height: 60,
                decoration: BoxDecoration(color: AppColours.subtle,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColours.line, width: 1.5, style: BorderStyle.solid)),
                child: const Center(child: Text('+ Add card',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.blue))))),
          ])),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: PrimaryButton(label: 'Save Flashcards', onPressed: () => context.go(AppRoutes.studySetReady))),
      ])),
    );
  }
}

class _FCEditCard extends StatelessWidget {
  const _FCEditCard({required this.num, required this.question, required this.answer, required this.difficulty});
  final int num;
  final String question, answer, difficulty;

  @override
  Widget build(BuildContext context) {
    final (diffColour, _) = switch (difficulty) {
      'Easy' => (AppColours.green, AppColours.greenLight),
      'Med'  => (AppColours.amber, AppColours.amberLight),
      _      => (AppColours.red, AppColours.redLight),
    };
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('⋮⋮ CARD $num', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColours.textMuted)),
          const Spacer(),
          Text(difficulty, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: diffColour)),
          const SizedBox(width: 10),
          const Icon(Icons.edit_outlined, size: 18, color: AppColours.textMuted),
          const SizedBox(width: 8),
          const Icon(Icons.delete_outline, size: 18, color: AppColours.red),
        ]),
        const SizedBox(height: 10),
        Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textDark)),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.only(left: 10),
          decoration: const BoxDecoration(border: Border(left: BorderSide(color: AppColours.blueMid, width: 3))),
          child: Text(answer, style: const TextStyle(fontSize: 13, color: AppColours.textMuted, height: 1.55))),
      ]));
  }
}

// ═══════════════════════════════════════════════════════
// S15 · EDIT QUIZ SCREEN
// ═══════════════════════════════════════════════════════

class EditQuizScreen extends ConsumerWidget {
  const EditQuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColours.bg,
      appBar: AppBar(backgroundColor: AppColours.bg, elevation: 0,
        leading: GestureDetector(onTap: () => context.go(AppRoutes.studySetReady),
          child: const Row(children: [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios, color: AppColours.blue, size: 20),
            Text('Edit Quiz', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.textDark)),
          ])),
        actions: [
          TextButton(onPressed: () => context.go(AppRoutes.studySetReady),
            child: const Text('Save', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.blue))),
        ]),
      body: SafeArea(child: Column(children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Align(alignment: Alignment.centerLeft,
            child: Text('3 of 8 questions · Multiple choice & true/false',
              style: TextStyle(fontSize: 13, color: AppColours.textMuted)))),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _QuizEditCard(num: 1, question: 'What is ½ of 10?',
              options: const ['2', '5', '10', '20'], correct: 1,
              explanation: '½ of 10 means we split 10 into 2 equal parts and take one part — that\'s 5.'),
            _QuizEditCard(num: 2, question: 'Are 1/2 and 2/4 equivalent fractions?',
              options: const ['True', 'False'], correct: 0,
              explanation: 'Both fractions equal one half — they look different but have the same value.'),
            _QuizEditCard(num: 3, question: 'The bottom number of a fraction is called the…',
              options: const ['Numerator', 'Denominator', 'Equator', 'Divisor'], correct: 1,
              explanation: 'Denominator names the parts the whole is split into.'),
          ])),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: PrimaryButton(label: 'Save Quiz', onPressed: () => context.go(AppRoutes.studySetReady))),
      ])),
    );
  }
}

class _QuizEditCard extends StatelessWidget {
  const _QuizEditCard({required this.num, required this.question, required this.options,
    required this.correct, required this.explanation});
  final int num, correct;
  final String question, explanation;
  final List<String> options;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColours.line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('$num', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.blue)),
        const Icon(Icons.edit_outlined, size: 18, color: AppColours.textMuted),
      ]),
      const Text('Multiple choice', style: TextStyle(fontSize: 12, color: AppColours.textMuted)),
      const SizedBox(height: 8),
      Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textDark)),
      const SizedBox(height: 10),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, childAspectRatio: 3.5, crossAxisSpacing: 8, mainAxisSpacing: 8,
        children: options.asMap().entries.map((e) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: e.key == correct ? AppColours.greenLight : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: e.key == correct ? AppColours.green : AppColours.line, width: 1.5)),
          child: Row(children: [
            if (e.key == correct) const Icon(Icons.check, size: 14, color: AppColours.green),
            if (e.key == correct) const SizedBox(width: 4),
            Text(e.value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: e.key == correct ? AppColours.green : AppColours.textDark)),
          ]))).toList()),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.only(top: 8),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColours.line))),
        child: Text(explanation, style: const TextStyle(fontSize: 12, color: AppColours.textMuted,
          fontStyle: FontStyle.italic, height: 1.55))),
    ]));
}
