import 'dart:async';
import 'package:english_conversation_app/domain/entities/level.dart';
import 'package:english_conversation_app/domain/repositories/conversation_repository.dart';

/// Cas d'usage : demarrer une conversation.
class StartConversation {
  final ConversationRepository repository;
  StartConversation(this.repository);

  Stream<String> call({required CefrLevel level, String? scenarioId}) =>
      repository.startConversationChunks(level: level, scenarioId: scenarioId);
}
