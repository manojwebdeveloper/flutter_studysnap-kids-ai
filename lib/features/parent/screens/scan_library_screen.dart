// ═══════════════════════════════════════════════════════
// S10 · SCAN LIBRARY   ·   S11 · OCR REVIEW
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../domain/entities/child_entity.dart';
import '../../../domain/entities/scan_entity.dart';
import '../providers/parent_provider.dart';
import 'parent_widgets.dart';

const _plusIcon = 'M12 5v14M5 12h14';
const _backIcon = 'M15 18l-6-6 6-6';
const _chevronDown = 'M6 9l6 6 6-6';

Color _subjectTint(String s) => switch (s) {
      'Maths' => AppColours.blue,
      'English' => AppColours.purple,
      'Science' => AppColours.teal,
      'Spelling' => AppColours.amber,
      _ => AppColours.blue,
    };

// ═══════════════════════════════════════════════════════
// S10 · SCAN LIBRARY
// ═══════════════════════════════════════════════════════

class ScanLibraryScreen extends ConsumerWidget {
  const ScanLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scansAsync = ref.watch(scanLibraryStreamProvider);
    final childrenAsync = ref.watch(childrenStreamProvider);
    final child = ref.watch(selectedChildNotifierProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColours.line)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.parent),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColours.line),
                      ),
                      child: Center(child: appSvg(_backIcon, size: 18, stroke: AppColours.ink, strokeWidth: 2)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Scan Library',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColours.ink)),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.ocrReview),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColours.blue,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(color: AppColours.blue.withOpacity(0.44), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          appSvg(_plusIcon, size: 16, stroke: Colors.white, strokeWidth: 2.5),
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
            // Child switcher
            childrenAsync.when(
              data: (children) => _ChildSwitcher(children: children, selectedId: child?.id, ref: ref),
              loading: () => const SizedBox(height: 60),
              error: (_, __) => const SizedBox(height: 60),
            ),
            // Content
            Expanded(
              child: ResponsiveBody(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      scansAsync.when(
                        data: (scans) {
                          final approved = scans.where((s) => s.status == 'approved').length;
                          final pending = scans.where((s) => s.status == 'needs_review').length;
                          return Row(
                            children: [
                              _StatCard(label: 'TOTAL', value: '${scans.length}'),
                              const SizedBox(width: 9),
                              _StatCard(label: 'APPROVED', value: '$approved', colour: AppColours.green),
                              const SizedBox(width: 9),
                              _StatCard(label: 'PENDING', value: '$pending', colour: AppColours.amber),
                            ],
                          );
                        },
                        loading: () => const SizedBox(height: 70),
                        error: (_, __) => const SizedBox(height: 70),
                      ),
                      const SizedBox(height: 14),
                      const _FilterRow(),
                      const SizedBox(height: 10),
                      scansAsync.when(
                        data: (scans) => scans.isEmpty
                            ? _EmptyState(onScan: () => context.go(AppRoutes.ocrReview))
                            : _ScanList(scans: scans),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildSwitcher extends StatelessWidget {
  const _ChildSwitcher({required this.children, required this.selectedId, required this.ref});
  final List<ChildEntity> children;
  final String? selectedId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox(height: 12);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: children.asMap().entries.map<Widget>((e) {
          final c = e.value;
          final sel = c.id == selectedId;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => ref.read(selectedChildNotifierProvider.notifier).selectChild(c.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? AppColours.blue.withOpacity(0.12) : AppColours.subtle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? AppColours.blue : Colors.transparent, width: 2),
                  ),
                  child: Row(
                    children: [
                      Avatar(emoji: c.avatar, size: 28, colour: _subjectTint(c.subjects.isNotEmpty ? c.subjects.first : 'Maths')),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.nickname,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: sel ? AppColours.blue : AppColours.ink)),
                            Text(c.yearGroup,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10.5, color: AppColours.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.colour = AppColours.ink});
  final String label, value;
  final Color colour;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColours.line),
          ),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: colour)),
              const SizedBox(height: 3),
              Text(label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColours.muted)),
            ],
          ),
        ),
      );
}

class _FilterRow extends StatefulWidget {
  const _FilterRow();
  @override
  State<_FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<_FilterRow> {
  int _sel = 0;
  static const _tabs = ['All', 'Maths', 'English', 'Science', 'Spelling'];
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _tabs.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => setState(() => _sel = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 7),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _sel == i ? AppColours.blue : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _sel == i ? AppColours.blue : AppColours.line, width: 1.5),
              ),
              child: Text(_tabs[i],
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _sel == i ? Colors.white : AppColours.muted)),
            ),
          ),
        ),
      );
}

class _ScanList extends StatelessWidget {
  const _ScanList({required this.scans});
  final List<ScanEntity> scans;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<ScanEntity>>{};
    for (final scan in scans) {
      grouped.putIfAbsent(_dateLabel(scan.scannedAt), () => []).add(scan);
    }
    return Column(
      children: grouped.entries
          .map((entry) => _DateFolder(label: entry.key, scans: entry.value))
          .toList(),
    );
  }

  static String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    if (date == today) return 'Today';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const wd = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const mo = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${wd[dt.weekday]} · ${dt.day} ${mo[dt.month]}';
  }
}

class _DateFolder extends StatefulWidget {
  const _DateFolder({required this.label, required this.scans});
  final String label;
  final List<ScanEntity> scans;
  @override
  State<_DateFolder> createState() => _DateFolderState();
}

class _DateFolderState extends State<_DateFolder> {
  bool _open = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _open ? 0 : -0.25,
                  duration: const Duration(milliseconds: 180),
                  child: appSvg(_chevronDown, size: 16, stroke: AppColours.muted, strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                IconSquare(
                  colour: AppColours.blue,
                  size: 24,
                  radius: 7,
                  child: const Text('📁', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Text(widget.label,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColours.ink)),
                const Spacer(),
                Text('${widget.scans.length} scan${widget.scans.length == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 12, color: AppColours.muted)),
              ],
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.only(left: 22, bottom: 6),
            child: Column(children: widget.scans.map((s) => _WsCard(scan: s)).toList()),
          ),
      ],
    );
  }
}

class _WsCard extends StatelessWidget {
  const _WsCard({required this.scan});
  final ScanEntity scan;

  String _typeEmoji() => switch (scan.scanMethod) { 'photo' => '📷', 'upload' => '🖼', _ => '📝' };
  String _time() =>
      '${scan.scannedAt.hour.toString().padLeft(2, '0')}:${scan.scannedAt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final tint = _subjectTint(scan.subject);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.line),
      ),
      child: Row(
        children: [
          // Mini thumbnail
          Container(
            width: 48,
            height: 60,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColours.subtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final w in const [1.0, 0.7, 0.85, 0.5])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: w,
                      child: Container(height: 3, color: tint.withOpacity(0.35)),
                    ),
                  ),
                const Spacer(),
                Text(_typeEmoji(), style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColours.ink)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Pill(scan.subject, bg: tint.withOpacity(0.14), fg: tint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('${scan.scanMethod} · ${_time()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColours.muted)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                StatusPill(scan.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onScan});
  final VoidCallback onScan;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColours.line),
        ),
        child: Column(
          children: [
            const Text('📷', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('No scans yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.ink)),
            const SizedBox(height: 6),
            const Text('Scan a worksheet to create your first study set.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColours.muted)),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Scan Now', onPressed: onScan),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════
// S11 · OCR REVIEW
// ═══════════════════════════════════════════════════════

class OcrReviewScreen extends ConsumerStatefulWidget {
  const OcrReviewScreen({super.key});
  @override
  ConsumerState<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends ConsumerState<OcrReviewScreen> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final state = ref.read(ocrReviewNotifierProvider);
    _ctrl = TextEditingController(text: state.extractedText);
    _ctrl.addListener(
        () => ref.read(ocrReviewNotifierProvider.notifier).editText(_ctrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ocrReviewNotifierProvider);
    final child = ref.watch(selectedChildNotifierProvider).valueOrNull;
    final confidencePct = (state.confidence * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColours.line)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.scan),
                    child: appSvg(_backIcon, size: 22, stroke: AppColours.blue, strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Review Extracted Text',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.ink)),
                  ),
                ],
              ),
            ),
            // Context strip
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColours.line)),
              ),
              child: Row(
                children: [
                  Avatar(emoji: child?.avatar ?? '🚀', size: 26, colour: AppColours.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${child?.nickname ?? ''} · ${child?.yearGroup ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.ink)),
                  ),
                  const SizedBox(width: 6),
                  Pill(state.subject, bg: _subjectTint(state.subject).withOpacity(0.14), fg: _subjectTint(state.subject)),
                  const SizedBox(width: 6),
                  Pill('$confidencePct% confident', bg: AppColours.greenLight, fg: AppColours.green),
                ],
              ),
            ),
            // Scroll content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColours.line),
                      ),
                      child: Row(
                        children: [
                          _WorksheetThumb(),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('fractions-worksheet.jpg',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.ink)),
                                const SizedBox(height: 2),
                                const Text('Scanned 11:42 · 218 words detected',
                                    style: TextStyle(fontSize: 12, color: AppColours.muted)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _OutlineBtn('📷 Rescan', () {}),
                                    const SizedBox(width: 8),
                                    _OutlineBtn('🖼 Replace', () {}),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('EXTRACTED TEXT · TAP TO EDIT',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.muted, letterSpacing: 0.4)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColours.blue, width: 2),
                        boxShadow: [
                          BoxShadow(color: AppColours.blue.withOpacity(0.10), blurRadius: 0, spreadRadius: 4),
                        ],
                      ),
                      child: TextField(
                        controller: _ctrl,
                        maxLines: null,
                        style: const TextStyle(fontSize: 13, color: AppColours.ink2, height: 1.75),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.confidence < 0.99)
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: AppColours.amber, size: 16),
                          SizedBox(width: 6),
                          Text('1 low-confidence word highlighted in amber',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.amber)),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColours.blue.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColours.blue.withOpacity(0.22)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('💡', style: TextStyle(fontSize: 15)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Check the text looks right before creating study activities. Only this text is used to generate content.',
                              style: TextStyle(fontSize: 12, color: AppColours.ink2, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom bar (in body, not bottomNavigationBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColours.line, width: 1.5),
                        ),
                        child: const Center(
                          child: Text('✏️ Edit',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColours.muted)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'Looks Good · Continue →',
                      onPressed: () => context.go(AppRoutes.chooseOutput),
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

class _WorksheetThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 64,
        height: 82,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColours.subtle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColours.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final w in const [1.0, 0.75, 0.9, 0.6, 0.8])
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: w,
                  child: Container(height: 3, color: AppColours.blue.withOpacity(0.3)),
                ),
              ),
          ],
        ),
      );
}

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColours.subtle,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.ink2)),
        ),
      );
}
