import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/error/result.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import 'providers/parent_provider.dart';

const _uuid = Uuid();
const _months = [
  '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

enum ScanOutcome { saved, cancelled, failed }

class ScanFlowResult {
  const ScanFlowResult(this.outcome, {this.message});
  final ScanOutcome outcome;
  final String? message;
}

/// Launches the native scanner, copies the resulting PDF into the app's
/// `documents/scans` folder, and records it against the selected child.
/// Never throws — always returns a [ScanFlowResult].
Future<ScanFlowResult> runScanFlow(WidgetRef ref) async {
  final child = ref.read(selectedChildNotifierProvider).valueOrNull;
  if (child == null) {
    return const ScanFlowResult(ScanOutcome.failed,
        message: 'Please select a child first.');
  }

  final result = await ref.read(documentScannerServiceProvider).scanToPdf();

  switch (result) {
    case Failure(error: final e):
      return ScanFlowResult(ScanOutcome.failed, message: e.message);
    case Success(data: final pdf):
      if (pdf == null) return const ScanFlowResult(ScanOutcome.cancelled);
      try {
        final dir = await getApplicationDocumentsDirectory();
        final scansDir = Directory(p.join(dir.path, 'scans'));
        if (!scansDir.existsSync()) scansDir.createSync(recursive: true);

        final id = _uuid.v4();
        final dest = p.join(scansDir.path, '$id.pdf');
        await File(pdf.pdfPath).copy(dest);

        final now = DateTime.now();
        final title = 'Scan ${now.day} ${_months[now.month]} ${now.year}';

        await ref.read(scanDaoProvider).insertScan(
              ScanLibraryTableCompanion.insert(
                id: id,
                childId: child.id,
                title: title,
                subject: '', // untagged until the parent adds one
                scanMethod: 'scan',
                scannedAt: now,
                pdfPath: Value(dest),
                pageCount: Value(pdf.pageCount),
              ),
            );

        // The free-scan counter is a FutureProvider — nudge it to recompute.
        ref.invalidate(scanCountProvider);
        return const ScanFlowResult(ScanOutcome.saved);
      } catch (_) {
        return const ScanFlowResult(ScanOutcome.failed,
            message: 'Could not save the scan. Please try again.');
      }
  }
}

/// Widget-facing entry point: runs the scan flow and handles navigation and
/// error feedback. On success it opens the scan library so the new scan shows.
Future<void> startScan(BuildContext context, WidgetRef ref) async {
  final result = await runScanFlow(ref);
  if (!context.mounted) return;
  switch (result.outcome) {
    case ScanOutcome.saved:
      context.go(AppRoutes.scan);
    case ScanOutcome.cancelled:
      break; // return quietly
    case ScanOutcome.failed:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Scanning failed.')),
      );
  }
}
