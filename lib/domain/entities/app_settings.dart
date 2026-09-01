import 'package:english_conversation_app/config/llm_providers.dart';

/// Reglages de l'application (provider + cle API + URL locale), persistes localement.
class AppSettings {
  final LlmProvider provider;
  final String apiKey;
  final String model;
  final bool autoSpeak;
  final String baseUrl;

  const AppSettings({
    this.provider = LlmProvider.openai,
    this.apiKey = '',
    this.model = '',
    this.autoSpeak = false,
    this.baseUrl = '',
  });

  AppSettings copyWith({
    LlmProvider? provider,
    String? apiKey,
    String? model,
    bool? autoSpeak,
    String? baseUrl,
  }) =>
      AppSettings(
        provider: provider ?? this.provider,
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
        autoSpeak: autoSpeak ?? this.autoSpeak,
        baseUrl: baseUrl ?? this.baseUrl,
      );
}
