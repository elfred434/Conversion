import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_conversation_app/domain/entities/app_settings.dart';
import 'package:english_conversation_app/presentation/providers/providers.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;
  SettingsNotifier(this._repository) : super(const AppSettings()) {
    _load();
  }

  void _load() async {
    state = await _repository.load();
  }

  void update({
    LlmProvider? provider,
    String? apiKey,
    String? model,
    bool? autoSpeak,
  }) {
    state = state.copyWith(
      provider: provider,
      apiKey: apiKey,
      model: model,
      autoSpeak: autoSpeak,
    );
  }

  Future<void> save() async {
    await _repository.save(state);
  }
}
