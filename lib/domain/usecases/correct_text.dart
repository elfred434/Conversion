import 'package:english_conversation_app/domain/entities/level.dart';
import 'package:english_conversation_app/domain/repositories/conversation_repository.dart';

/// Cas d'usage : corriger une phrase de l'utilisateur.
class CorrectText {
  final ConversationRepository repository;
  CorrectText(this.repository);

  Future<String?> call({required String userText, required CefrLevel level}) =>
      repository.correctText(userText, level: level);
}
