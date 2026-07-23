import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import '../network/api_client.dart';
import '../../data/datasources/local/document_scanner_service.dart';
import '../../data/datasources/remote/claude_service.dart';
import '../../data/repositories/repository_impls.dart';
import '../../domain/entities/scan_entity.dart';
import '../../domain/repositories/repositories.dart';

// ── Infrastructure ────────────────────────────────────────

/// The single SQLite database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Shared Dio client (singleton).
final apiClientProvider = Provider<ApiClient>((_) => ApiClient.instance);

/// Secure storage (for Parent PIN).
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ),
);

/// SharedPreferences (for non-sensitive settings).
final sharedPrefsProvider = FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
);

/// Local authentication (Face ID / fingerprint).
final localAuthProvider = Provider<LocalAuthentication>(
  (_) => LocalAuthentication(),
);

// ── Remote services ───────────────────────────────────────

final claudeServiceProvider = Provider<ClaudeService>(
  (ref) => ClaudeService(ref.watch(apiClientProvider)),
);

/// Native document scanner (ML Kit / VisionKit → PDF).
final documentScannerServiceProvider = Provider<DocumentScannerService>(
  (_) => const DocumentScannerService(),
);

/// Loads a single saved scan by id (used to carry the current scan through the
/// review → output flow instead of relying on a provider that can reset).
final scanByIdProvider =
    FutureProvider.autoDispose.family<ScanEntity?, String>((ref, id) async {
  final row = await ref.watch(scanDaoProvider).getById(id);
  if (row == null) return null;
  return ScanEntity(
    id: row.id,
    childId: row.childId,
    title: row.title,
    subject: row.subject,
    imagePath: row.imagePath,
    extractedText: row.extractedText,
    confidence: row.confidence,
    scanMethod: row.scanMethod,
    status: row.status,
    studySetId: row.studySetId,
    pdfPath: row.pdfPath,
    pageCount: row.pageCount,
    scannedAt: row.scannedAt,
  );
});

// ── DAOs ──────────────────────────────────────────────────

final childrenDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).childrenDao,
);
final studySetsDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).studySetsDao,
);
final flashcardsDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).flashcardsDao,
);
final quizDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).quizDao,
);
final scanDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).scanDao,
);
final progressDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).progressDao,
);

// ── Repositories ──────────────────────────────────────────

final childrenRepositoryProvider = Provider<ChildrenRepository>(
  (ref) => ChildrenRepositoryImpl(ref.watch(childrenDaoProvider)),
);

final studySetsRepositoryProvider = Provider<StudySetsRepository>(
  (ref) => StudySetsRepositoryImpl(ref.watch(studySetsDaoProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(secureStorageProvider),
    ref.watch(localAuthProvider),
  ),
);

final generationRepositoryProvider = Provider<GenerationRepository>(
  (ref) => GenerationRepositoryImpl(ref.watch(claudeServiceProvider)),
);
