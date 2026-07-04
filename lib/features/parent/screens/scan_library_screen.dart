// ═══════════════════════════════════════════════════════
// S10 · SCAN LIBRARY SCREEN
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../domain/entities/scan_entity.dart';
import '../providers/parent_provider.dart';

class ScanLibraryScreen extends ConsumerWidget {
  const ScanLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scansAsync   = ref.watch(scanLibraryStreamProvider);
    final countAsync   = ref.watch(scanCountProvider);
    final childrenAsync = ref.watch(childrenStreamProvider);
    final child        = ref.watch(selectedChildNotifierProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColours.bg,
      body: SafeArea(child: Column(children: [
        // Top bar
        Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(children: [
            GestureDetector(onTap: () => context.go(AppRoutes.parent),
              child: const Row(children: [
                Icon(Icons.arrow_back_ios, color: AppColours.blue, size: 20),
                Text('Scan Library', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColours.textDark)),
              ])),
            const Spacer(),
            GestureDetector(onTap: () => context.go(AppRoutes.ocrReview),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColours.teal, borderRadius: BorderRadius.circular(12)),
                child: const Text('New Scan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)))),
          ])),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Kid tabs
            childrenAsync.when(
              data: (children) => SizedBox(height: 52,
                child: ListView(scrollDirection: Axis.horizontal, children: children.map((c) {
                  final sel = child?.id == c.id;
                  return GestureDetector(
                    onTap: () => ref.read(selectedChildNotifierProvider.notifier).selectChild(c.id),
                    child: AnimatedContainer(duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      ])),
                  );
                }).toList())),
              loading: () => const SizedBox(height: 52),
              error: (_, __) => const SizedBox(height: 52),
            ),
            const SizedBox(height: 14),

            // Stats
            scansAsync.when(
              data: (scans) {
                final approved = scans.where((s) => s.status == 'approved').length;
                final pending  = scans.where((s) => s.status == 'needs_review').length;
                return Row(children: [
                  _StatBox(value: '${scans.length}', label: '📁 Total'),
                  const SizedBox(width: 9),
                  _StatBox(value: '$approved', label: '✓ Approved', valueColour: AppColours.green),
                  const SizedBox(width: 9),
                  _StatBox(value: '$pending',  label: '● Pending',  valueColour: AppColours.amber),
                ]);
              },
              loading: () => const SizedBox(height: 62),
              error: (_, __) => const SizedBox(height: 62),
            ),
            const SizedBox(height: 14),

            // Filter tabs
            const _FilterRow(),
            const SizedBox(height: 4),

            // Scan list
            scansAsync.when(
              data: (scans) => scans.isEmpty
                  ? _EmptyState(onScan: () => context.go(AppRoutes.ocrReview))
                  : _ScanList(scans: scans),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 20),
          ]),
        )),
      ])),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label, this.valueColour = AppColours.textDark});
  final String value, label;
  final Color valueColour;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: valueColour)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColours.textMuted)),
      ])),
  );
}

class _FilterRow extends StatefulWidget {
  const _FilterRow();
  @override State<_FilterRow> createState() => _FilterRowState();
}
class _FilterRowState extends State<_FilterRow> {
  int _sel = 0;
  static const _tabs = ['All', 'Maths', 'English', 'Science', 'Spelling'];
  @override
  Widget build(BuildContext context) => SizedBox(height: 38,
    child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _tabs.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => setState(() => _sel = i),
        child: AnimatedContainer(duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(right: 7),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _sel == i ? AppColours.blue : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _sel == i ? AppColours.blue : AppColours.line, width: 1.5)),
          child: Text(_tabs[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: _sel == i ? Colors.white : AppColours.textMuted))),
      )));
}

class _ScanList extends StatelessWidget {
  const _ScanList({required this.scans});
  final List<ScanEntity> scans;

  @override
  Widget build(BuildContext context) {
    // Group by date
    final grouped = <String, List<ScanEntity>>{};
    for (final scan in scans) {
      final key = _dateLabel(scan.scannedAt);
      grouped.putIfAbsent(key, () => []).add(scan);
    }
    return Column(children: grouped.entries.map((entry) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.textMuted)),
            Text('${entry.value.length} scan${entry.value.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 12, color: AppColours.textMuted)),
          ])),
        AppCard(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: entry.value.asMap().entries.map((e) {
            final scan = e.value;
            final isLast = e.key == entry.value.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColours.line))),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(
                  color: AppColours.subtle, borderRadius: BorderRadius.circular(11)),
                  child: Center(child: Text(_scanIcon(scan.scanMethod), style: const TextStyle(fontSize: 20)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(scan.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textDark)),
                  const SizedBox(height: 3),
                  Row(children: [
                    SubjectBadge(scan.subject),
                    const SizedBox(width: 6),
                    Text('${scan.scanMethod} · ${_timeLabel(scan.scannedAt)}',
                      style: const TextStyle(fontSize: 12, color: AppColours.textMuted)),
                  ]),
                  const SizedBox(height: 5),
                  Row(children: [StatusPill(scan.status)]),
                ])),
                const Icon(Icons.chevron_right, color: AppColours.textMuted),
              ]),
            );
          }).toList())),
      ])).toList());
  }

  String _dateLabel(DateTime dt) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date  = DateTime(dt.year, dt.month, dt.day);
    if (date == today)                     return '📁 Today · ${dt.day} ${_month(dt.month)} ${dt.year}';
    if (date == today.subtract(const Duration(days: 1))) return '📁 Yesterday';
    return '📁 ${_weekday(dt.weekday)} · ${dt.day} ${_month(dt.month)} ${dt.year}';
  }

  String _timeLabel(DateTime dt) =>
      '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

  String _month(int m) => const ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];
  String _weekday(int d) => const ['','Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d];
  String _scanIcon(String method) => switch (method) { 'photo' => '📷', 'upload' => '🖼', _ => '📝' };
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onScan});
  final VoidCallback onScan;
  @override
  Widget build(BuildContext context) => AppCard(child: Column(children: [
    const SizedBox(height: 16),
    const Text('📷', style: TextStyle(fontSize: 48)),
    const SizedBox(height: 12),
    const Text('No scans yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.textDark)),
    const SizedBox(height: 6),
    const Text('Scan a worksheet to create your first study set.',
      textAlign: TextAlign.center, style: AppTextStyles.bodySmall),
    const SizedBox(height: 16),
    PrimaryButton(label: 'Scan Now', onPressed: onScan),
    const SizedBox(height: 8),
  ]));
}

// ═══════════════════════════════════════════════════════
// S11 · OCR REVIEW SCREEN
// ═══════════════════════════════════════════════════════

class OcrReviewScreen extends ConsumerStatefulWidget {
  const OcrReviewScreen({super.key});
  @override ConsumerState<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends ConsumerState<OcrReviewScreen> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final state = ref.read(ocrReviewNotifierProvider);
    _ctrl = TextEditingController(text: state.extractedText);
    _ctrl.addListener(() =>
        ref.read(ocrReviewNotifierProvider.notifier).editText(_ctrl.text));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ocrReviewNotifierProvider);
    final child = ref.watch(selectedChildNotifierProvider).valueOrNull;
    final confidencePct = (state.confidence * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppColours.bg,
      appBar: AppBar(backgroundColor: AppColours.bg, elevation: 0,
        leading: GestureDetector(onTap: () => context.go(AppRoutes.scan),
          child: const Row(children: [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios, color: AppColours.blue, size: 20),
            Text('Review Extracted Text', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.textDark)),
          ]))),
      body: SafeArea(child: Column(children: [
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Sub-header
            Row(children: [
              Text(child?.avatar ?? '🚀', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('${child?.nickname ?? ''} · ${child?.yearGroup ?? ''}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.textDark)),
              const SizedBox(width: 6),
              SubjectBadge(state.subject),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColours.greenLight, borderRadius: BorderRadius.circular(7)),
                child: Text('$confidencePct% confident',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.green))),
            ]),
            const SizedBox(height: 14),

            // File card
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(
                  color: AppColours.subtle, borderRadius: BorderRadius.circular(11)),
                  child: const Center(child: Text('📄', style: TextStyle(fontSize: 20)))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('fractions-worksheet.jpg',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColours.textDark)),
                  const Text('Scanned 11:42 · 218 words detected',
                    style: TextStyle(fontSize: 12, color: AppColours.textMuted)),
                ]),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _OutlineBtn('📷 Rescan', () {}),
                const SizedBox(width: 8),
                _OutlineBtn('🖼 Replace', () {}),
              ]),
            ])),

            const SectionLabel('EXTRACTED TEXT · TAP TO EDIT'),
            Container(decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColours.blue, width: 2)),
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                style: const TextStyle(fontSize: 13, color: AppColours.textInk, height: 1.75),
                decoration: const InputDecoration(contentPadding: EdgeInsets.all(14),
                  border: InputBorder.none, filled: false),
              )),
            const SizedBox(height: 12),

            // Warnings
            if (state.confidence < 0.99)
              Row(children: const [
                Icon(Icons.warning_amber_rounded, color: AppColours.amber, size: 16),
                SizedBox(width: 6),
                Text('1 low-confidence word highlighted in amber',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.amber)),
              ]),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Icon(Icons.lightbulb_outline, color: AppColours.textMuted, size: 16),
              SizedBox(width: 6),
              Expanded(child: Text(
                'Check the text looks right before creating study activities. Only this text is used to generate content.',
                style: TextStyle(fontSize: 12, color: AppColours.textMuted, height: 1.55))),
            ]),
            const SizedBox(height: 20),
          ]),
        )),

        // Bottom bar
        Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Row(children: [
            Expanded(child: GestureDetector(onTap: () {},
              child: Container(height: 54, decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColours.line, width: 1.5)),
                child: const Center(child: Text('✏️ Edit',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColours.textMuted)))))),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: PrimaryButton(
              label: 'Looks Good · Continue →',
              onPressed: () => context.go(AppRoutes.chooseOutput),
            )),
          ])),
      ])),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColours.line, width: 1.5)),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.textInk))));
}
