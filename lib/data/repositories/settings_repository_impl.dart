import 'package:english_conversation_app/data/datasources/local/settings_local_datasource.dart';
import 'package:english_conversation_app/domain/entities/app_settings.dart';
import 'package:english_conversation_app/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource local;
  SettingsRepositoryImpl(this.local);

  @override
  Future<AppSettings> load() => local.load();

  @override
  Future<void> save(AppSettings settings) => local.save(settings);
}
