import 'package:english_conversation_app/domain/entities/level.dart';
import 'package:english_conversation_app/domain/repositories/user_repository.dart';

/// Cas d'usage : lire/écrire le niveau de l'utilisateur.
class GetUserProfile {
  final UserRepository repository;
  GetUserProfile(this.repository);

  Future<CefrLevel?> call() => repository.getLevel();
  Future<void> save(CefrLevel level) => repository.saveLevel(level);
}
