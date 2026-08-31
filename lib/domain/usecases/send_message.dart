import 'dart:async';
import 'package:english_conversation_app/domain/entities/conversation_message.dart';
import 'package:english_conversation_app/domain/entities/level.dart';
import 'package:english_conversation_app/domain/repositories/conversation_repository.dart';

/// Cas d'usage : envoyer un message utilisateur.
class SendMessage {
  final ConversationRepository repository;
  SendMessage(this.repository);

  Stream<String> call({
    required CefrLevel level,
    required List<ConversationMessage> history,
    required String userText,
    String? scenarioId,
  }) =>
      repository.sendMessageChunks(
        level: level,
        history: history,
        userText: userText,
        scenarioId: scenarioId,
      );
}
