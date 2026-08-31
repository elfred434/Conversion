import 'dart:async';
import 'package:english_conversation_app/domain/entities/conversation_message.dart';
import 'package:english_conversation_app/domain/entities/level.dart';

/// Contrat de la couche domaine pour la conversation avec le LLM.
abstract class ConversationRepository {
  /// Demarre la conversation et diffuse le message d'accueil (flux de texte).
  Stream<String> startConversationChunks({
    required CefrLevel level,
    String? scenarioId,
  });

  /// Envoie le message utilisateur et diffuse la reponse (flux de texte).
  Stream<String> sendMessageChunks({
    required CefrLevel level,
    required List<ConversationMessage> history,
    required String userText,
    String? scenarioId,
  });

  /// Corrige une phrase de l'utilisateur (best-effort, peut renvoyer null).
  Future<String?> correctText(String userText, {required CefrLevel level});
}
