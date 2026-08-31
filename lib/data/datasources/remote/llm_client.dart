import 'dart:async';
import 'package:english_conversation_app/domain/entities/conversation_message.dart';
import 'package:english_conversation_app/domain/entities/level.dart';

/// Abstraction sur un fournisseur LLM externe.
///
/// Les implementations concretes (OpenAI, Gemini, ...) traduisent cet
/// contrat vers l'API correspondante. La couche domaine/data ne depend
/// que de cette interface -> on peut changer de fournisseur sans toucher
/// au reste de l'app.
abstract class LlmClient {
  /// Diffuse la reponse du LLM morceau par morceau (streaming).
  Stream<String> streamChat({
    required ConversationMessage systemPrompt,
    required List<ConversationMessage> history,
    required ConversationMessage userMessage,
  });

  /// Corrige une phrase (peut renvoyer null en cas d'echec).
  Future<String?> correctText(String userText, {required CefrLevel level});
}
