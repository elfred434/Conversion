import 'package:english_conversation_app/domain/entities/level.dart';

/// Contrat de la couche domaine pour le profil utilisateur (niveau choisi).
abstract class UserRepository {
  Future<CefrLevel?> getLevel();
  Future<void> saveLevel(CefrLevel level);
}
