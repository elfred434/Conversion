import 'package:english_conversation_app/domain/entities/app_settings.dart';
import 'package:english_conversation_app/domain/repositories/settings_repository.dart';

class GetSettings {
  final SettingsRepository repository;
  GetSettings(this.repository);
  Future<AppSettings> call() => repository.load();
}
