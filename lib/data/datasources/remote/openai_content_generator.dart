import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/config/app_env.dart';
import '../../../core/error/result.dart';
import '../../models/study_set_request.dart';
import '../../../domain/repositories/ai_content_generator.dart' show AiContentGenerator;
import 'ai_content_shared.dart';

/// Turns scanned-worksheet content into structured study content using
/// OpenAI's chat completions endpoint (with vision support for an attached
/// worksheet image). The API key is read from the env (OPENAI_API_KEY) —
/// never hardcoded — and a missing key is a friendly failure, not a crash.
class OpenAiContentGenerator implements AiContentGenerator {
  OpenAiContentGenerator({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<Result<StudySetResponse>> generate(StudySetRequest request) async {
    final key = AppEnv.openaiApiKey;
    if (key.isEmpty) {
      return const Result.failure(
        GenerationException('No OpenAI API key found. Add OPENAI_API_KEY to your .env file.'),
      );
    }

    try {
      final content = <Map<String, dynamic>>[
        {'type': 'text', 'text': buildStudyContentPrompt(request)},
      ];

      final imagePath = request.imagePath;
      if (imagePath != null && imagePath.isNotEmpty) {
        final bytes = await File(imagePath).readAsBytes();
        final b64 = base64Encode(bytes);
        final mime = mimeTypeForImagePath(imagePath);
        content.add({
          'type': 'image_url',
          'image_url': {'url': 'data:$mime;base64,$b64'},
        });
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '${AppEnv.openaiBaseUrl}/chat/completions',
        options: Options(headers: {
          'Authorization': 'Bearer $key',
          'Content-Type': 'application/json',
        }),
        data: {
          'model': AppEnv.openaiModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You always reply with strictly valid JSON only — no markdown, no commentary.',
            },
            {'role': 'user', 'content': content},
          ],
          'max_tokens': 4096,
        },
      );

      final data = response.data;
      final choices = data?['choices'] as List<dynamic>?;
      final text = choices == null || choices.isEmpty
          ? null
          : (choices.first as Map<String, dynamic>)['message']?['content'] as String?;

      return parseStudyContentResponse(text, request, providerLabel: 'GPT');
    } on DioException catch (e, st) {
      return Result.failure(GenerationException(_friendlyDioMessage(e), stackTrace: st));
    } catch (e, st) {
      return Result.failure(
        GenerationException('GPT generation failed. Please try again.', stackTrace: st),
      );
    }
  }

  String _friendlyDioMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'GPT request timed out. Please check your connection and try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please try again.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        if (status == 401) return 'The OpenAI API key was rejected. Please check OPENAI_API_KEY in your .env file.';
        final message = (e.response?.data is Map)
            ? (e.response?.data['error']?['message'] as String?)
            : null;
        return message ?? 'GPT request failed (server error $status). Please try again.';
      default:
        return 'GPT generation failed. Please try again.';
    }
  }
}
