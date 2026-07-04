/// A discriminated union representing success or failure.
/// Used as the return type for all repository and use-case methods
/// so that callers are forced to handle both cases explicitly.
///
/// Usage:
/// ```dart
/// final result = await repo.getStudySets();
/// result.when(
///   success: (data) => ...,
///   failure: (error) => ...,
/// );
/// ```
sealed class Result<T> {
  const Result();

  /// Creates a successful result.
  const factory Result.success(T data) = Success<T>;

  /// Creates a failed result.
  const factory Result.failure(AppException error) = Failure<T>;

  /// Returns [true] if this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns [true] if this is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Returns the success value, or [null] if this is a [Failure].
  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Failure() => null,
      };

  /// Returns the error, or [null] if this is a [Success].
  AppException? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  /// Pattern-matches over the result.
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) =>
      switch (this) {
        Success(:final data) => success(data),
        Failure(:final error) => failure(error),
      };

  /// Maps the success value to a new type.
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success(:final data) => Result.success(transform(data)),
        Failure(:final error) => Result.failure(error),
      };
}

/// Successful result wrapper.
final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

/// Failed result wrapper.
final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppException error;
}

// ─────────────────────────────────────────────────────────
// Exception hierarchy
// ─────────────────────────────────────────────────────────

/// Base class for all application exceptions.
sealed class AppException implements Exception {
  const AppException(this.message, {this.stackTrace});
  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// Network-related errors (no internet, timeout, server error).
final class NetworkException extends AppException {
  const NetworkException(super.message, {
    this.statusCode,
    super.stackTrace,
  });
  final int? statusCode;
}

/// Local database errors.
final class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.stackTrace});
}

/// Validation errors (bad input, missing required fields).
final class ValidationException extends AppException {
  const ValidationException(super.message, {super.stackTrace});
}

/// Authentication / PIN errors.
final class AuthException extends AppException {
  const AuthException(super.message, {super.stackTrace});
}

/// OCR / scanning errors.
final class ScanException extends AppException {
  const ScanException(super.message, {super.stackTrace});
}

/// AI generation errors (Claude API failures).
final class GenerationException extends AppException {
  const GenerationException(super.message, {super.stackTrace});
}

/// Unexpected / unknown errors.
final class UnknownException extends AppException {
  const UnknownException(super.message, {super.stackTrace});
}
