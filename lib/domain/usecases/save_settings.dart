import 'package:english_conversation_app/domain/entities/app_settings.dart';
import 'package:english_conversation_app/domain/repositories/settings_repository.dart';

class SaveSettings {
  final SettingsRepository repository;
  SaveSettings(this.repository);
  Future<void> call(AppSettings settings) => repository.save(settings);
}
