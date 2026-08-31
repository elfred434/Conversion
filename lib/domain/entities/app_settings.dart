import 'package:english_conversation_app/config/llm_providers.dart';

/// Parametres LLM choisis par l'utilisateur (lues au runtime, stockees localement).
class AppSettings {
  final LlmProvider provider;
  final String apiKey;
  final String model;

  const AppSettings({
    this.provider = LlmProvider.openai,
    this.apiKey = '',
    this.model = '',
  });

  AppSettings copyWith({LlmProvider? provider, String? apiKey, String? model}) =>
      AppSettings(
        provider: provider ?? this.provider,
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
      );
}
