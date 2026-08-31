import 'package:english_conversation_app/domain/entities/level.dart';
import 'package:english_conversation_app/domain/repositories/user_repository.dart';
import 'package:english_conversation_app/data/datasources/local/profile_local_datasource.dart';

/// Implementation du UserRepository via la source de donnees locale.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this.local);
  final ProfileLocalDataSource local;

  @override
  Future<CefrLevel?> getLevel() => local.getLevel();

  @override
  Future<void> saveLevel(CefrLevel level) => local.saveLevel(level);
}
