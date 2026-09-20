import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/anthropic_content_generator.dart';
import '../../data/datasources/remote/gemini_content_generator.dart';
import '../../data/datasources/remote/openai_content_generator.dart';
import '../../domain/repositories/ai_content_generator.dart';

/// The three interchangeable AI content-generation providers.
enum AiProvider { gpt, claude, gemini }

/// The single selection point for which AI provider is active. Change the
/// value returned here (or later, read it from a settings toggle or a
/// cost-based routing rule) to switch providers app-wide — everything else
/// depends only on [activeAiContentGeneratorProvider] below, never on a
/// specific provider.
final activeAiProviderProvider = Provider<AiProvider>((_) => AiProvider.gpt);

/// The concrete [AiContentGenerator] for the currently active provider.
/// The rest of the app must read this — never construct a provider
/// implementation directly — so switching providers stays a one-line change
/// to [activeAiProviderProvider].
final activeAiContentGeneratorProvider = Provider<AiContentGenerator>((ref) {
  return switch (ref.watch(activeAiProviderProvider)) {
    AiProvider.gpt => OpenAiContentGenerator(),
    AiProvider.claude => AnthropicContentGenerator(),
    AiProvider.gemini => GeminiContentGenerator(),
  };
});
