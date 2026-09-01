import 'package:english_conversation_app/domain/entities/level.dart';

/// Reglages de l'application (provider + cle API), persistes localement.
class AppSettings {
  final LlmProvider provider;
  final String apiKey;
  final String model;
  final bool autoSpeak;

  const AppSettings({
    this.provider = LlmProvider.openai,
    this.apiKey = '',
    this.model = '',
    this.autoSpeak = false,
  });

  AppSettings copyWith({
    LlmProvider? provider,
    String? apiKey,
    String? model,
    bool? autoSpeak,
  }) =>
      AppSettings(
        provider: provider ?? this.provider,
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
        autoSpeak: autoSpeak ?? this.autoSpeak,
      );
}
