import 'package:english_conversation_app/config/llm_providers.dart';

/// Parametres LLM choisis par l'utilisateur (lues au runtime, stockees localement).
class AppSettings {
  final LlmProvider provider;
  final String apiKey;
  final String model;
  final bool autoSpeak;
  /// Cle + region Azure Speech (evaluation phonetique).
  final String azureKey;
  final String azureRegion;

  const AppSettings({
    this.provider = LlmProvider.openai,
    this.apiKey = '',
    this.model = '',
    this.autoSpeak = false,
    this.azureKey = '',
    this.azureRegion = '',
  });

  AppSettings copyWith({
    LlmProvider? provider,
    String? apiKey,
    String? model,
    bool? autoSpeak,
    String? azureKey,
    String? azureRegion,
  }) =>
      AppSettings(
        provider: provider ?? this.provider,
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
        autoSpeak: autoSpeak ?? this.autoSpeak,
        azureKey: azureKey ?? this.azureKey,
        azureRegion: azureRegion ?? this.azureRegion,
      );
}
