// ═══════════════════════════════════════════════════════
// S06 · ADD CHILD  ·  S07 · YEAR GROUP  ·  S08 · SUBJECTS
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/onboarding_provider.dart';

// ── Shared bits ───────────────────────────────────────────

Widget _sectionLabel(String text) => Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColours.muted,
        letterSpacing: 0.4,
      ),
    );

Widget _stepSegments(int filled) => Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        return Container(
          width: 24,
          height: 4,
          margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
          decoration: BoxDecoration(
            color: i < filled ? AppColours.blue : AppColours.line,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );

Widget _title(String text) => Text(
      text,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColours.ink,
        letterSpacing: -0.5,
      ),
    );

// ═══════════════════════════════════════════════════════
// S06 · ADD CHILD
// ═══════════════════════════════════════════════════════

class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});
  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final cell = (MediaQuery.of(context).size.width - 48 - 30) / 4;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: NavBackIconButton(onPressed: () => context.go(AppRoutes.parentPin)),
              ),
              const SizedBox(height: 12),
              _title('Add Your Child'),
              const SizedBox(height: 8),
              const Text(
                'Use a nickname and choose a fun avatar. We never ask for full name, school or date of birth.',
                style: TextStyle(fontSize: 15, color: AppColours.muted, height: 1.5),
              ),
              const SizedBox(height: 22),
              _sectionLabel('Nickname'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _ctrl,
                  maxLength: 20,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColours.ink,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Buddy, Star, Champ',
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColours.blue, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColours.blue, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColours.blue, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _sectionLabel('Pick an Avatar'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppConstants.avatarEmojis.map((emoji) {
                  final selected = state.selectedAvatar == emoji;
                  return GestureDetector(
                    onTap: () => notifier.setAvatar(emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: cell,
                      height: cell,
                      decoration: BoxDecoration(
                        color: selected ? AppColours.blue.withOpacity(0.15) : AppColours.subtle,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected ? AppColours.blue : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColours.blue.withOpacity(0.18),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Continue',
                onPressed: state.nickname.isNotEmpty ? () => context.go(AppRoutes.yearGroup) : null,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// S07 · YEAR GROUP
// ═══════════════════════════════════════════════════════

class YearGroupScreen extends ConsumerWidget {
  const YearGroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NavBackIconButton(onPressed: () => context.go(AppRoutes.addChild)),
                  _stepSegments(3),
                ],
              ),
              const SizedBox(height: 12),
              _title('Choose Learning Level'),
              const SizedBox(height: 8),
              const Text(
                "We'll use this to make explanations easier or harder.",
                style: TextStyle(fontSize: 15, color: AppColours.muted, height: 1.5),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: AppConstants.yearGroups.length,
                  itemBuilder: (_, i) {
                    final year = AppConstants.yearGroups[i];
                    final age = AppConstants.yearGroupAges[i];
                    final sel = state.selectedYearGroup == year;
                    return GestureDetector(
                      onTap: () => notifier.setYearGroup(year),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: sel ? AppColours.blue.withOpacity(0.10) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: sel ? AppColours.blue : AppColours.line,
                            width: sel ? 2 : 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              year,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: sel ? AppColours.blue : AppColours.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(age, style: const TextStyle(fontSize: 11, color: AppColours.muted)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              PrimaryButton(label: 'Continue', onPressed: () => context.go(AppRoutes.subjects)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// S08 · SUBJECTS
// ═══════════════════════════════════════════════════════

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  static const _tints = <String, Color>{
    'Maths': AppColours.blue,
    'English': AppColours.purple,
    'Science': AppColours.teal,
    'Spelling': AppColours.amber,
    'Reading': AppColours.blue,
    'History': AppColours.amber,
    'Geography': AppColours.teal,
    'Languages': AppColours.blue,
    'Other': AppColours.muted,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final count = state.selectedSubjects.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NavBackIconButton(onPressed: () => context.go(AppRoutes.yearGroup)),
                  _stepSegments(4),
                ],
              ),
              const SizedBox(height: 12),
              _title('Choose Subjects'),
              const SizedBox(height: 8),
              const Text(
                'Pick the subjects your child wants to practise. You can change these anytime.',
                style: TextStyle(fontSize: 15, color: AppColours.muted, height: 1.5),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppConstants.subjects.map((s) {
                      final label = s['label']!;
                      final emoji = s['emoji']!;
                      final sel = state.selectedSubjects.contains(label);
                      final tint = _tints[label] ?? AppColours.muted;
                      return GestureDetector(
                        onTap: () => notifier.toggleSubject(label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: sel ? tint.withOpacity(0.15) : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: sel ? tint : AppColours.line, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: sel ? tint : AppColours.ink,
                                ),
                              ),
                              if (sel) ...[
                                const SizedBox(width: 6),
                                appSvg('M5 12l4 4L19 7', size: 14, stroke: tint, strokeWidth: 2.5),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    count == 0
                        ? 'No subjects selected'
                        : '$count subject${count == 1 ? '' : 's'} selected',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.muted),
                  ),
                ),
              ),
              PrimaryButton(
                label: 'Finish Setup',
                isLoading: state.isLoading,
                onPressed: count > 0
                    ? () async {
                        final ok = await notifier.finishSetup();
                        if (ok && context.mounted) context.go(AppRoutes.parent);
                      }
                    : null,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
