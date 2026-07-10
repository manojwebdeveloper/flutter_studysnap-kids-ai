import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../domain/entities/child_entity.dart';
import '../../../domain/entities/study_set_entity.dart';
import '../providers/parent_provider.dart';
import 'parent_widgets.dart';

const _homeIcon = 'M3 11l9-7 9 7v9a2 2 0 01-2 2h-4v-7H9v7H5a2 2 0 01-2-2v-9z';
const _swapIcon = 'M16 3l4 4-4 4M20 7H10M8 21l-4-4 4-4M4 17h10';
const _scanIcon =
    'M3 7V5a2 2 0 012-2h2M17 3h2a2 2 0 012 2v2M21 17v2a2 2 0 01-2 2h-2M7 21H5a2 2 0 01-2-2v-2M7 12h10';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studySetsAsync = ref.watch(studySetsStreamProvider);
    final childrenAsync = ref.watch(childrenStreamProvider);

    return Scaffold(
      backgroundColor: AppColours.background,
      body: _maybeTablet(
        context,
        SafeArea(
        child: Column(
          children: [
            // ── Title row ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
              child: Row(
                children: [
                  appSvg(_homeIcon, size: 28, stroke: AppColours.blue, strokeWidth: 2),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Parent Dashboard',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: AppColours.blue,
                        letterSpacing: -0.7,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.switchKid),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColours.blue.withOpacity(0.22), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: AppColours.blue.withOpacity(0.10), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Center(child: appSvg(_swapIcon, size: 20, stroke: AppColours.blue, strokeWidth: 2)),
                    ),
                  ),
                ],
              ),
            ),
            // ── Greeting ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _greeting(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColours.blue.withOpacity(0.7),
                  ),
                ),
              ),
            ),
            // ── Children row ───────────────────────────────
            childrenAsync.when(
              data: (children) => _ChildrenRow(children: children, ref: ref),
              loading: () => const SizedBox(height: 118),
              error: (_, __) => const SizedBox(height: 118),
            ),
            // ── Scrollable sheet ───────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColours.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                  boxShadow: [
                    BoxShadow(color: AppColours.blue.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, -6)),
                  ],
                ),
                child: ResponsiveBody(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ScanCard(),
                        const SizedBox(height: 14),
                        _StudySetsCard(
                          async: studySetsAsync,
                          onViewAll: () => context.go(AppRoutes.studySets),
                        ),
                        const SizedBox(height: 14),
                        _PracticeAreasCard(onCreate: () => context.go(AppRoutes.practiceAreas)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _maybeTablet(BuildContext context, Widget content) {
    if (!isTablet(context)) return content;
    return Row(
      children: [
        const _ParentSidebar(),
        Expanded(child: content),
      ],
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}

// ── Tablet sidebar (parent) ───────────────────────────────

class _ParentSidebar extends StatelessWidget {
  const _ParentSidebar();

  static const _items = [
    (Icons.home_outlined, 'Dashboard', AppRoutes.parent),
    (Icons.document_scanner_outlined, 'Scan', AppRoutes.scan),
    (Icons.folder_outlined, 'Study Sets', AppRoutes.studySets),
    (Icons.bar_chart_outlined, 'Progress', AppRoutes.progress),
    (Icons.settings_outlined, 'Settings', AppRoutes.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).matchedLocation;
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppColours.blue.withOpacity(0.06), blurRadius: 16, offset: const Offset(4, 0))],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  SizedBox(width: 54, height: 54, child: FittedBox(child: LogoMark())),
                  SizedBox(width: 12),
                  Text('StudySnap',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColours.blue, letterSpacing: -0.4)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._items.map((item) {
              final active = current == item.$3;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: GestureDetector(
                  onTap: () => context.go(item.$3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: active ? AppColours.blue.withOpacity(0.10) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(item.$1, size: 22, color: active ? AppColours.blue : AppColours.muted),
                        const SizedBox(width: 12),
                        Text(item.$2,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: active ? AppColours.blue : AppColours.muted)),
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

// ── Children row ──────────────────────────────────────────

class _ChildrenRow extends StatelessWidget {
  const _ChildrenRow({required this.children, required this.ref});
  final List<ChildEntity> children;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final valid = children
        .where((c) => c.nickname.isNotEmpty && !c.nickname.startsWith('['))
        .toList();
    final selectedId = ref.watch(selectedChildNotifierProvider).valueOrNull?.id;

    return SizedBox(
      height: 118,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
        child: Row(
          children: [
            ...valid.asMap().entries.map((e) {
              final c = e.value;
              final colour = childColour(e.key);
              final selected = c.id == selectedId;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => ref.read(selectedChildNotifierProvider.notifier).selectChild(c.id),
                  child: Column(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: colour, width: 4),
                          boxShadow: selected
                              ? [BoxShadow(color: colour.withOpacity(0.30), blurRadius: 14, offset: const Offset(0, 6))]
                              : [BoxShadow(color: colour.withOpacity(0.14), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: colour.withOpacity(0.14)),
                          child: Center(child: Text(c.avatar, style: const TextStyle(fontSize: 32))),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 86,
                        child: Text(
                          c.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.ink),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Add Kid
            Column(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColours.muted.withOpacity(0.55), width: 3),
                  ),
                  child: const Center(child: Icon(Icons.add, color: AppColours.muted, size: 28)),
                ),
                const SizedBox(height: 8),
                const Text('Add Kid',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scan card ─────────────────────────────────────────────

class _ScanCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final used = ref.watch(scanCountProvider).valueOrNull ?? 0;
    final remaining = (AppConstants.freeScanLimit - used).clamp(0, AppConstants.freeScanLimit);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColours.line),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconSquare(
                colour: AppColours.blue,
                child: appSvg(_scanIcon, size: 22, stroke: AppColours.blue, strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Scan a Worksheet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.ink)),
              ),
              Pill('$remaining of ${AppConstants.freeScanLimit} free',
                  bg: AppColours.amberLight, fg: AppColours.amber),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ScanOption('📷', 'Take Photo', 'Best quality', () => context.go(AppRoutes.scan)),
              const SizedBox(width: 8),
              _ScanOption('🖼', 'Upload', 'From files', () => context.go(AppRoutes.scan)),
              const SizedBox(width: 8),
              _ScanOption('📝', 'Paste Text', 'Type or paste', () => context.go(AppRoutes.scan)),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => context.go(AppRoutes.scan),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColours.blue, AppColours.purple],
                ),
                boxShadow: [
                  BoxShadow(color: AppColours.blue.withOpacity(0.44), blurRadius: 14, offset: const Offset(0, 6)),
                ],
              ),
              child: const Center(
                child: Text('Start Scanning',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOption extends StatelessWidget {
  const _ScanOption(this.emoji, this.label, this.sub, this.onTap);
  final String emoji, label, sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
            decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 5),
                Text(label,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColours.ink)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 10, color: AppColours.muted)),
              ],
            ),
          ),
        ),
      );
}

// ── Study sets card ───────────────────────────────────────

class _StudySetsCard extends StatelessWidget {
  const _StudySetsCard({required this.async, required this.onViewAll});
  final AsyncValue<List<StudySetEntity>> async;
  final VoidCallback onViewAll;

  static String _emoji(String subject) => switch (subject) {
        'Maths' => '➗',
        'English' => '📖',
        'Science' => '🧪',
        'Spelling' => '✏️',
        _ => '📚',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColours.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('Study Sets', actionLabel: 'View all', onAction: onViewAll),
          const SizedBox(height: 8),
          async.when(
            loading: () => const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator(color: AppColours.blue, strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (sets) {
              final show = sets.take(3).toList();
              if (show.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('No study sets yet. Scan a worksheet to get started!',
                      style: TextStyle(fontSize: 13, color: AppColours.muted)),
                );
              }
              return Column(
                children: show.asMap().entries.map((e) {
                  final set = e.value;
                  final isLast = e.key == show.length - 1;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: isLast ? null : const Border(bottom: BorderSide(color: AppColours.line)),
                    ),
                    child: Row(
                      children: [
                        IconSquare(colour: AppColours.blue, size: 40, child: Text(_emoji(set.subject), style: const TextStyle(fontSize: 20))),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(set.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.ink)),
                              Text('${set.subject} · ${set.cardCount} cards · ${set.questionCount}Q',
                                  style: const TextStyle(fontSize: 11, color: AppColours.muted)),
                            ],
                          ),
                        ),
                        StatusPill(set.status),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Practice areas card ───────────────────────────────────

class _PracticeAreasCard extends StatelessWidget {
  const _PracticeAreasCard({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColours.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('Practice Areas', actionLabel: 'Create set →', onAction: onCreate),
          const SizedBox(height: 10),
          const Text(
            'Turn weak topics into a fresh practice set your child can work through.',
            style: TextStyle(fontSize: 13, color: AppColours.muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}
