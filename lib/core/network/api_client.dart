import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_env.dart';
import '../config/app_constants.dart';
import '../error/result.dart';

/// Singleton Dio client configured for the Anthropic Claude API.
/// Includes:
///   - Base URL + headers
///   - Timeout config
///   - Pretty logging (dev only)
///   - Retry interceptor
///   - Centralised error mapping → AppException
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.anthropicBaseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        sendTimeout: AppConstants.apiTimeout,
        headers: {
          'x-api-key': AppEnv.anthropicApiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
      ),
    );

    // Logging — only in dev builds
    if (AppEnv.isDevelopment) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
        ),
      );
    }

    // Retry interceptor
    dio.interceptors.add(_RetryInterceptor(dio));

    return dio;
  }

  /// Makes a POST request to [path] with [body].
  /// Returns [Result.success] on 2xx, [Result.failure] otherwise.
  Future<Result<Map<String, dynamic>>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final data = response.data;
      if (data == null) {
        return const Result.failure(
          NetworkException('Empty response from server'),
        );
      }
      return Result.success(data);
    } on DioException catch (e, st) {
      return Result.failure(_mapDioError(e, st));
    } catch (e, st) {
      return Result.failure(
        UnknownException(e.toString(), stackTrace: st),
      );
    }
  }

  /// Maps a [DioException] to the appropriate [AppException].
  AppException _mapDioError(DioException e, StackTrace st) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Request timed out. Please check your connection.',
          stackTrace: st,
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please try again.',
        );
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        final message = e.response?.data?['error']?['message'] as String? ??
            'Server error ($status)';
        return NetworkException(message, statusCode: status, stackTrace: st);
      default:
        return NetworkException(
          e.message ?? 'An unexpected network error occurred.',
          stackTrace: st,
        );
    }
  }
}

/// Automatically retries failed requests up to [maxRetries] times
/// with exponential back-off.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;
  static const int maxRetries = AppConstants.apiMaxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final extra = err.requestOptions.extra;
    final retryCount = (extra['retryCount'] as int?) ?? 0;

    final shouldRetry = retryCount < maxRetries &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError ||
            (err.response?.statusCode ?? 0) >= 500);

    if (!shouldRetry) {
      return handler.next(err);
    }

    final delay = Duration(milliseconds: 300 * (retryCount + 1));
    await Future.delayed(delay);

    err.requestOptions.extra['retryCount'] = retryCount + 1;
    try {
      final response = await _dio.request<dynamic>(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          extra: err.requestOptions.extra,
        ),
      );
      handler.resolve(response);
    } catch (e) {
      handler.next(err);
    }
  }
}
