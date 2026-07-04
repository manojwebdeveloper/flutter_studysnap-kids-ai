import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/children_dao.dart';
import '../../core/database/daos/study_sets_dao.dart';
import '../../core/database/daos/flashcards_dao.dart';
import '../../core/database/daos/quiz_dao.dart';
import '../../core/database/daos/scan_dao.dart';
import '../../core/database/daos/progress_dao.dart';
import '../../core/database/tables/children_table.dart';
import '../../core/database/tables/study_sets_table.dart';
import '../../core/database/tables/flashcards_table.dart';
import '../../core/database/tables/quiz_questions_table.dart';
import '../../core/database/tables/scan_library_table.dart';
import '../../core/database/tables/progress_table.dart';
import '../../core/error/result.dart';
import '../../core/config/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/entities/study_set_entity.dart';
import '../../domain/entities/flashcard_entity.dart';
import '../../domain/entities/quiz_question_entity.dart';
import '../../domain/entities/scan_entity.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/repositories/repositories.dart';
import '../../data/datasources/remote/claude_service.dart';
import '../../data/models/study_set_request.dart';
import 'mappers.dart';

const _uuid = Uuid();

// ─────────────────────────────────────────────────────────
// CHILDREN
// ─────────────────────────────────────────────────────────

class ChildrenRepositoryImpl implements ChildrenRepository {
  const ChildrenRepositoryImpl(this._dao);
  final ChildrenDao _dao;

  @override
  Stream<List<ChildEntity>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(Mappers.childFromRow).toList());

  @override
  Future<Result<List<ChildEntity>>> getAll() async {
    try {
      final rows = await _dao.getAll();
      return Result.success(rows.map(Mappers.childFromRow).toList());
    } catch (e, st) {
      return Result.failure(DatabaseException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<ChildEntity?>> getById(String id) async {
    try {
      final row = await _dao.getById(id);
      return Result.success(row != null ? Mappers.childFromRow(row) : null);
    } catch (e, st) {
      return Result.failure(DatabaseException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> create(ChildEntity child) async {
    try {
      await _dao.insertChild(Mappers.childToCompanion(child));
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> update(ChildEntity child) async {
    try {
      await _dao.updateChild(Mappers.childToCompanion(child));
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dao.deleteChild(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> addRewards(
    String id, {
    required int xp,
    required int stars,
  }) async {
    try {
      await _dao.addRewards(id, xp, stars);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> updateStreak(String id, int streak) async {
    try {
      await _dao.updateStreak(id, streak);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseException(e.toString(), stackTrace: st));
    }
  }
}

// ─────────────────────────────────────────────────────────
// STUDY SETS
// ─────────────────────────────────────────────────────────

class StudySetsRepositoryImpl implements StudySetsRepository {
  const StudySetsRepositoryImpl(this._dao);
  final StudySetsDao _dao;

  @override
  Stream<List<StudySetEntity>> watchByChild(String childId) =>
      _dao.watchByChild(childId).map(
            (rows) => rows.map(Mappers.studySetFromRow).toList(),
          );

  @override
  Future<Result<List<StudySetEntity>>> getApproved(String childId) async {
    try {
      final rows = await _dao.getApproved(childId);
      return Result.success(rows.map(Mappers.studySetFromRow).toList());
    } catch (e, st) {
      return Result.failure(DatabaseException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<String>> create(StudySetEntity set) async {
    try {
      final id = await _dao.insertSet(Mappers.studySetToCompanion(set));
      return Result.success(id);
    } catch (e, st) {
      return Result.failure(DatabaseException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> approve(String id) async {
    try {
      await _dao.approve(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> updateStatus(String id, String status) async {
    try {
      await _dao.updateStatus(id, status);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dao.deleteSet(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseException(e.toString(), stackTrace: st));
    }
  }
}

// ─────────────────────────────────────────────────────────
// AUTH (Parent PIN + Biometrics)
// ─────────────────────────────────────────────────────────

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._storage, this._localAuth);

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  @override
  Future<Result<void>> setPin(String pin) async {
    try {
      await _storage.write(
        key: AppConstants.secureKeyParentPin,
        value: pin,
      );
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(AuthException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<bool>> verifyPin(String pin) async {
    try {
      final stored = await _storage.read(key: AppConstants.secureKeyParentPin);
      return Result.success(stored == pin);
    } catch (e, st) {
      return Result.failure(AuthException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<bool> hasPin() async {
    final pin = await _storage.read(key: AppConstants.secureKeyParentPin);
    return pin != null && pin.isNotEmpty;
  }

  @override
  Future<Result<void>> clearPin() async {
    try {
      await _storage.delete(key: AppConstants.secureKeyParentPin);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(AuthException(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<bool>> authenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return const Result.success(false);

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Parent Mode',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return Result.success(authenticated);
    } catch (e, st) {
      return Result.failure(AuthException(e.toString(), stackTrace: st));
    }
  }
}

// ─────────────────────────────────────────────────────────
// GENERATION (Claude API)
// ─────────────────────────────────────────────────────────

class GenerationRepositoryImpl implements GenerationRepository {
  const GenerationRepositoryImpl(this._service);
  final ClaudeService _service;

  @override
  Future<Result<StudySetResponse>> generateStudySet(
    StudySetRequest request,
  ) =>
      _service.generateStudySet(request);
}
