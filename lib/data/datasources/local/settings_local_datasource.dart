import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_conversation_app/config/llm_providers.dart';
import 'package:english_conversation_app/domain/entities/app_settings.dart';

class SettingsLocalDataSource {
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final p = prefs.getString('llm_provider');
    final provider = LlmProvider.values.firstWhere(
      (e) => e.name == p,
      orElse: () => LlmProvider.openai,
    );
    return AppSettings(
      provider: provider,
      apiKey: prefs.getString('llm_api_key') ?? '',
      model: prefs.getString('llm_model') ?? '',
    );
  }

  Future<void> save(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('llm_provider', s.provider.name);
    await prefs.setString('llm_api_key', s.apiKey);
    await prefs.setString('llm_model', s.model);
  }
}
