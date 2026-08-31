/// Configuration globale, lue depuis les --dart-define.
///
/// Exemple de lancement :
///   flutter run --dart-define=OPENAI_API_KEY=sk-... --dart-define=LLM_PROVIDER=openai
///   flutter run --dart-define=GEMINI_API_KEY=... --dart-define=LLM_PROVIDER=gemini
class AppConfig {
  const AppConfig._();

  static const String openAiApiKey =
      String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const String geminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String llmProvider =
      String.fromEnvironment('LLM_PROVIDER', defaultValue: 'openai');
  static const String openAiBaseUrl = String.fromEnvironment(
    'OPENAI_BASE_URL',
    defaultValue: 'https://api.openai.com/v1',
  );
}
