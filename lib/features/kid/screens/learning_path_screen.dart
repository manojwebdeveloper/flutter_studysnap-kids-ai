import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../domain/entities/study_set_entity.dart';
import '../../parent/providers/insights_provider.dart';
import '../providers/kid_provider.dart';

const _lockIcon =
    'M6 10V8a6 6 0 1112 0v2M5 10h14a1 1 0 011 1v9a1 1 0 01-1 1H5a1 1 0 01-1-1v-9a1 1 0 011-1z';

enum NodeState { done, current, locked }

class _PathNode {
  const _PathNode(this.symbol, this.label, this.state, this.stars);
  final String symbol, label;
  final NodeState state;
  final int stars;
}

class LearningPathScreen extends ConsumerStatefulWidget {
  const LearningPathScreen({super.key});
  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  int _tab = 0;

  static const _offsets = [60.0, 120.0, 60.0, 0.0, 60.0, 120.0];

  static String _symbolFor(StudySetEntity s) => switch (s.subject) {
        'Maths' => '➗',
        'English' => '📖',
        'Science' => '🧪',
        'Spelling' => '✏️',
        'Reading' => '📚',
        _ => '📘',
      };

  @override
  Widget build(BuildContext context) {
    final sets = ref.watch(approvedSetsProvider).valueOrNull ?? const <StudySetEntity>[];
    final progress = ref.watch(childProgressProvider).valueOrNull;
    final streak = ref.watch(activeChildProvider).valueOrNull?.streak ?? 0;

    final completedSetIds = <String>{
      if (progress != null) for (final s in progress.sessions) s.studySetId,
    };

    // Distinct subjects (tab list) from the child's approved sets.
    final subjects = <String>[];
    for (final s in sets) {
      if (!subjects.contains(s.subject)) subjects.add(s.subject);
    }
    final tabIndex = subjects.isEmpty ? 0 : _tab.clamp(0, subjects.length - 1);
    final selectedSubject = subjects.isEmpty ? null : subjects[tabIndex];
    final subjectSets = selectedSubject == null
        ? const <StudySetEntity>[]
        : sets.where((s) => s.subject == selectedSubject).toList();

    // Build path nodes with real completion state derived from progress.
    final nodes = <_PathNode>[];
    var currentAssigned = false;
    for (final s in subjectSets) {
      final done = completedSetIds.contains(s.id);
      final NodeState st;
      if (done) {
        st = NodeState.done;
      } else if (!currentAssigned) {
        st = NodeState.current;
        currentAssigned = true;
      } else {
        st = NodeState.locked;
      }
      var stars = 0;
      if (done && progress != null) {
        final recs = progress.sessions.where((p) => p.studySetId == s.id);
        if (recs.isNotEmpty) {
          final best = recs.map((p) => p.percentage).reduce((a, b) => a > b ? a : b);
          stars = (best / 100 * 3).round();
        }
      }
      nodes.add(_PathNode(_symbolFor(s), s.title, st, stars));
    }
    final doneCount = nodes.where((n) => n.state == NodeState.done).length;

    return Scaffold(
      backgroundColor: AppColours.kidBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Gradient header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.kid),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Icon(Icons.arrow_back, color: Colors.white, size: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Learning Path',
                            style: GoogleFonts.nunito(fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(999)),
                        child: Text('🔥 $streak', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (subjects.isNotEmpty)
                    Row(
                      children: List.generate(subjects.length, (i) {
                        final on = tabIndex == i;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _tab = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: on ? Colors.white : Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(subjects[i],
                                  style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: on ? AppColours.kidBlue : Colors.white)),
                            ),
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ),
            // Progress strip
            if (selectedSubject != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    Text('$selectedSubject · ${subjectSets.isEmpty ? '' : subjectSets.first.yearGroup}',
                        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.kidMuted)),
                    const Spacer(),
                    Text('$doneCount/${subjectSets.length} done',
                        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: AppColours.kidGreen)),
                  ],
                ),
              ),
            // Path
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 12, bottom: 110),
                child: Column(
                  children: [
                    if (subjectSets.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 30, bottom: 10),
                        child: KidEmptyState(
                          emoji: '🗺️',
                          title: 'No lessons yet',
                          message: 'Ask a grown-up to scan a worksheet to build your learning path!',
                        ),
                      )
                    else ...[
                      ...nodes.asMap().entries.map((e) {
                        final node = e.value;
                        final prev = e.key == 0 ? null : nodes[e.key - 1];
                        return Column(
                          children: [
                            if (e.key != 0)
                              Container(
                                margin: EdgeInsets.only(left: _offsets[e.key % _offsets.length]),
                                width: 3,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: prev?.state == NodeState.done ? AppColours.kidGreen.withOpacity(0.44) : AppColours.line,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.only(left: _offsets[e.key % _offsets.length]),
                              child: _NodeWidget(
                                node: node,
                                onTap: node.state == NodeState.current ? () => context.go(AppRoutes.flashcards) : null,
                              ),
                            ),
                          ],
                        );
                      }),
                      if (nodes.any((n) => n.state == NodeState.locked)) ...[
                        const SizedBox(height: 16),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 280),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColours.line, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              const Text('🔒', style: TextStyle(fontSize: 22)),
                              const SizedBox(height: 6),
                              Text('Keep going to unlock the next lessons!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.kidMuted)),
                            ],
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EXPLORE ACTIVITIES',
                              style: GoogleFonts.nunito(
                                  fontSize: 11, fontWeight: FontWeight.w900, color: AppColours.kidMuted, letterSpacing: 0.8)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _activityCard(context, '✏️', 'Spell It', AppColours.kidYellow, AppRoutes.typeAnswer),
                              const SizedBox(width: 10),
                              _activityCard(context, '📝', 'Writing', AppColours.kidPurple, AppRoutes.writingStudio),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _activityCard(context, '🔊', 'Listen & Pick', AppColours.kidGreen, AppRoutes.phonicsListen),
                              const SizedBox(width: 10),
                              _activityCard(context, '🎤', 'Speak Up', AppColours.kidPink, AppRoutes.speakAloud),
                            ],
                          ),
                        ],
                      ),
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

  Widget _activityCard(BuildContext context, String emoji, String label, Color colour, String route) => Expanded(
        child: GestureDetector(
          onTap: () => context.go(route),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colour.withOpacity(0.33), width: 2),
              boxShadow: [BoxShadow(color: colour.withOpacity(0.18), offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: colour.withOpacity(0.14), borderRadius: BorderRadius.circular(11)),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 19))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label,
                      style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                ),
              ],
            ),
          ),
        ),
      );
}

class _NodeWidget extends StatefulWidget {
  const _NodeWidget({required this.node, this.onTap});
  final _PathNode node;
  final VoidCallback? onTap;
  @override
  State<_NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<_NodeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: node.state == NodeState.done
                          ? const LinearGradient(colors: [AppColours.kidGreen, AppColours.kidGreenDark])
                          : node.state == NodeState.current
                              ? const LinearGradient(colors: [AppColours.kidBlue, AppColours.kidPurple])
                              : null,
                      color: node.state == NodeState.locked ? const Color(0xFFE2E8F0) : null,
                      border: node.state == NodeState.current ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: node.state == NodeState.current
                          ? [BoxShadow(color: AppColours.kidBlue.withOpacity(0.4 * _pulse.value), blurRadius: 18, spreadRadius: 2)]
                          : node.state == NodeState.done
                              ? [BoxShadow(color: AppColours.kidGreenDark.withOpacity(0.5), blurRadius: 0, offset: const Offset(0, 4))]
                              : null,
                    ),
                    child: Center(
                      child: node.state == NodeState.locked
                          ? appSvg(_lockIcon, size: 24, stroke: AppColours.kidMuted, strokeWidth: 2)
                          : Text(node.symbol,
                              style: TextStyle(
                                  fontSize: node.symbol.length > 2 ? 18 : 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                    ),
                  ),
                ),
                if (node.state == NodeState.done)
                  const Positioned(top: -4, right: -2, child: Text('👑', style: TextStyle(fontSize: 22))),
                if (node.state == NodeState.current)
                  Positioned(
                    top: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColours.kidYellow, borderRadius: BorderRadius.circular(999)),
                      child: Text('START', style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF78350F))),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(node.label,
              style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: node.state == NodeState.locked ? AppColours.kidMuted : AppColours.kidInk)),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final earned = i < node.stars;
              const star = Text('⭐', style: TextStyle(fontSize: 11));
              return earned ? star : const Opacity(opacity: 0.3, child: ColorFiltered(colorFilter: _greyscaleLP, child: star));
            }),
          ),
        ],
      ),
    );
  }
}

const _greyscaleLP = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);
