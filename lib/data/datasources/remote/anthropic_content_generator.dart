import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/config/app_env.dart';
import '../../../core/error/result.dart';
import '../../models/study_set_request.dart';
import '../../../domain/repositories/ai_content_generator.dart' show AiContentGenerator;
import 'ai_content_shared.dart';

/// Turns scanned-worksheet content into structured study content using
/// Anthropic's messages endpoint (with image support for an attached
/// worksheet image). The API key is read from the env (ANTHROPIC_API_KEY) —
/// never hardcoded — and a missing key is a friendly failure, not a crash.
///
/// This is one of the three interchangeable [AiContentGenerator]
/// implementations selected via `activeAiContentGeneratorProvider`; it is
/// independent of the legacy `ClaudeService`.
class AnthropicContentGenerator implements AiContentGenerator {
  AnthropicContentGenerator({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<Result<StudySetResponse>> generate(StudySetRequest request) async {
    final key = AppEnv.anthropicApiKey;
    if (key.isEmpty) {
      return const Result.failure(
        GenerationException('No Anthropic API key found. Add ANTHROPIC_API_KEY to your .env file.'),
      );
    }

    try {
      final content = <Map<String, dynamic>>[
        {'type': 'text', 'text': buildStudyContentPrompt(request)},
      ];

      final imagePath = request.imagePath;
      if (imagePath != null && imagePath.isNotEmpty) {
        final bytes = await File(imagePath).readAsBytes();
        content.add({
          'type': 'image',
          'source': {
            'type': 'base64',
            'media_type': mimeTypeForImagePath(imagePath),
            'data': base64Encode(bytes),
          },
        });
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '${AppEnv.anthropicBaseUrl}/messages',
        options: Options(headers: {
          'x-api-key': key,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        }),
        data: {
          'model': AppEnv.claudeModel,
          'max_tokens': 4096,
          'messages': [
            {'role': 'user', 'content': content},
          ],
        },
      );

      final blocks = response.data?['content'] as List<dynamic>?;
      final text = blocks
          ?.whereType<Map<String, dynamic>>()
          .where((b) => b['type'] == 'text')
          .map((b) => b['text'] as String? ?? '')
          .join('');

      return parseStudyContentResponse(text, request, providerLabel: 'Claude');
    } on DioException catch (e, st) {
      return Result.failure(GenerationException(_friendlyDioMessage(e), stackTrace: st));
    } catch (e, st) {
      return Result.failure(
        GenerationException('Claude generation failed. Please try again.', stackTrace: st),
      );
    }
  }

  String _friendlyDioMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Claude request timed out. Please check your connection and try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please try again.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        if (status == 401) return 'The Anthropic API key was rejected. Please check ANTHROPIC_API_KEY in your .env file.';
        final message = (e.response?.data is Map)
            ? (e.response?.data['error']?['message'] as String?)
            : null;
        return message ?? 'Claude request failed (server error $status). Please try again.';
      default:
        return 'Claude generation failed. Please try again.';
    }
  }
}
