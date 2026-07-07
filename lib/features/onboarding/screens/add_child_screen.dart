// ═══════════════════════════════════════════════════════
// S06 · ADD CHILD SCREEN
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/onboarding_provider.dart';

class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});
  @override ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: ref.read(onboardingNotifierProvider).nickname.isNotEmpty
          ? ref.read(onboardingNotifierProvider).nickname
          : '',
    );
    _ctrl.addListener(() {
      ref.read(onboardingNotifierProvider.notifier).setNickname(_ctrl.text);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColours.bg,
      appBar: AppBar(backgroundColor: AppColours.bg, elevation: 0,
        leading: NavBackIconButton(
          onPressed: () => context.go(AppRoutes.parentPin))),
      body: SafeArea(child: ResponsiveBody(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add Your Child',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColours.textDark, letterSpacing: -.3)),
          const SizedBox(height: 8),
          const Text('Use a nickname and choose a fun avatar. We never ask for full name, school or date of birth.',
            style: AppTextStyles.body),

          const SectionLabel('NICKNAME'),
          TextField(
            controller: _ctrl,
            maxLength: 20,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColours.textDark),
            decoration: const InputDecoration(
              hintText: 'e.g. Aarav, Mia, Buddy',
              counterText: '', // hide the character counter
            ),
          ),

          const SectionLabel('PICK AN AVATAR'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: AppConstants.avatarEmojis.length,
            itemBuilder: (_, i) {
              final emoji = AppConstants.avatarEmojis[i];
              final selected = state.selectedAvatar == emoji;
              return GestureDetector(
                onTap: () => notifier.setAvatar(emoji),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: selected ? AppColours.blueLight : AppColours.subtle,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? AppColours.blue : Colors.transparent, width: 2.5),
                    boxShadow: selected ? [BoxShadow(color: AppColours.blue.withOpacity(.18), blurRadius: 14, offset: const Offset(0, 4))] : [],
                  ),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ]),
      ))),
      bottomNavigationBar: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: PrimaryButton(
          label: 'Continue',
          onPressed: state.nickname.isNotEmpty ? () => context.go(AppRoutes.yearGroup) : null,
        ),
      )),
    );
  }
}

// ═══════════════════════════════════════════════════════
// S07 · YEAR GROUP SCREEN
// ═══════════════════════════════════════════════════════

class YearGroupScreen extends ConsumerWidget {
  const YearGroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColours.bg,
      appBar: AppBar(backgroundColor: AppColours.bg, elevation: 0,
        leading: NavBackIconButton(
          onPressed: () => context.go(AppRoutes.addChild))),
      body: SafeArea(child: ResponsiveBody(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Choose Learning Level',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColours.textDark, letterSpacing: -.3)),
          const SizedBox(height: 8),
          const Text("We'll use this to make explanations easier or harder.", style: AppTextStyles.body),
          const SizedBox(height: 20),
          Expanded(child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.4),
            itemCount: AppConstants.yearGroups.length,
            itemBuilder: (_, i) {
              final year = AppConstants.yearGroups[i];
              final age  = AppConstants.yearGroupAges[i];
              final sel  = state.selectedYearGroup == year;
              return GestureDetector(
                onTap: () => notifier.setYearGroup(year),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: sel ? AppColours.blueLight : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: sel ? AppColours.blue : AppColours.line, width: sel ? 2 : 1.5)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(year, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: sel ? AppColours.blue : AppColours.textDark)),
                    const SizedBox(height: 2),
                    Text(age, style: const TextStyle(fontSize: 12, color: AppColours.textMuted)),
                  ]),
                ),
              );
            },
          )),
        ]),
      ))),
      bottomNavigationBar: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: PrimaryButton(label: 'Continue', onPressed: () => context.go(AppRoutes.subjects)),
      )),
    );
  }
}

// ═══════════════════════════════════════════════════════
// S08 · SUBJECTS SCREEN
// ═══════════════════════════════════════════════════════

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  static const _subjectColours = {
    'Maths':     (AppColours.blueLight,   AppColours.blue),
    'English':   (AppColours.purpleLight, AppColours.purple),
    'Science':   (AppColours.tealLight,   AppColours.teal),
    'Spelling':  (AppColours.amberLight,  AppColours.amber),
    'Reading':   (AppColours.blueLight,   AppColours.blue),
    'History':   (AppColours.purpleLight, AppColours.purple),
    'Geography': (AppColours.tealLight,   AppColours.teal),
    'Languages': (AppColours.amberLight,  AppColours.amber),
    'Other':     (AppColours.blueLight,   AppColours.blue),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final count    = state.selectedSubjects.length;

    return Scaffold(
      backgroundColor: AppColours.bg,
      appBar: AppBar(backgroundColor: AppColours.bg, elevation: 0,
        leading: NavBackIconButton(
          onPressed: () => context.go(AppRoutes.yearGroup))),
      body: SafeArea(child: ResponsiveBody(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Choose Subjects',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColours.textDark, letterSpacing: -.3)),
          const SizedBox(height: 8),
          const Text("Pick the subjects your child wants to practise. You can change these anytime.", style: AppTextStyles.body),
          const SizedBox(height: 20),
          Expanded(child: SingleChildScrollView(child: Wrap(spacing: 10, runSpacing: 10,
            children: AppConstants.subjects.map((s) {
              final label   = s['label']!;
              final emoji   = s['emoji']!;
              final sel     = state.selectedSubjects.contains(label);
              final (bg, fg) = _subjectColours[label] ?? (AppColours.subtle, AppColours.textMuted);
              return GestureDetector(
                onTap: () => notifier.toggleSubject(label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? bg : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: sel ? fg : AppColours.line, width: 1.5)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(emoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: sel ? fg : AppColours.textInk)),
                    if (sel) ...[const SizedBox(width: 5),
                      Text('✓', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg))],
                  ]),
                ),
              );
            }).toList(),
          ))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(child: Text(
              count == 0 ? 'No subjects selected' : '$count subject${count == 1 ? '' : 's'} selected',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.textMuted)))),
        ]),
      ))),
      bottomNavigationBar: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: PrimaryButton(
          label: 'Finish Setup',
          isLoading: state.isLoading,
          onPressed: count > 0 ? () async {
            final ok = await notifier.finishSetup();
            if (ok && context.mounted) context.go(AppRoutes.parent);
          } : null,
        ),
      )),
    );
  }
}
