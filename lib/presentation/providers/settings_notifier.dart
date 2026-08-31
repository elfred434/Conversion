import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_conversation_app/config/llm_providers.dart';
import 'package:english_conversation_app/domain/entities/app_settings.dart';
import 'package:english_conversation_app/domain/repositories/settings_repository.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;
  SettingsNotifier(this._repository) : super(const AppSettings());

  void update({LlmProvider? provider, String? apiKey, String? model}) {
    state = state.copyWith(
      provider: provider,
      apiKey: apiKey,
      model: model,
    );
  }

  void setSettings(AppSettings s) {
    state = s;
  }

  Future<void> load() async => state = await _repository.load();
  Future<void> save() => _repository.save(state);
}
