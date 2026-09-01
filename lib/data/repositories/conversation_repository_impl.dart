import 'dart:async';
import 'package:english_conversation_app/domain/entities/conversation_message.dart';
import 'package:english_conversation_app/domain/entities/level.dart';
import 'package:english_conversation_app/domain/entities/correction_result.dart';
import 'package:english_conversation_app/domain/entities/scenario.dart';
import 'package:english_conversation_app/domain/repositories/conversation_repository.dart';
import 'package:english_conversation_app/data/datasources/remote/llm_client.dart';

/// Implementation du ConversationRepository.
///
/// Construit le system prompt (niveau + scenario) et delegue le flux de
/// texte au LlmClient injecte.
class ConversationRepositoryImpl implements ConversationRepository {
  ConversationRepositoryImpl({required this.llmClient});

  final LlmClient llmClient;

  ConversationMessage _buildSystem(CefrLevel level, String? scenarioId) {
    Scenario? scenario;
    for (final s in kScenarios) {
      if (s.id == scenarioId) {
        scenario = s;
        break;
      }
    }
    return ConversationMessage.system(
      buildSystemPrompt(
        level,
        scenarioPrompt: scenario?.prompt,
        correct: scenario?.correct ?? true,
      ),
    );
  }

  @override
  Stream<String> startConversationChunks({
    required CefrLevel level,
    String? scenarioId,
  }) {
    final system = _buildSystem(level, scenarioId);
    final userMessage = ConversationMessage.user("Hello! I'm ready to practice.");
    return llmClient.streamChat(
      systemPrompt: system,
      history: const [],
      userMessage: userMessage,
    );
  }

  @override
  Stream<String> sendMessageChunks({
    required CefrLevel level,
    required List<ConversationMessage> history,
    required String userText,
    String? scenarioId,
  }) {
    final system = _buildSystem(level, scenarioId);
    final clean = history
        .where((m) => m.role != MessageRole.system)
        .toList();
    final userMessage = ConversationMessage.user(userText);
    return llmClient.streamChat(
      systemPrompt: system,
      history: clean,
      userMessage: userMessage,
    );
  }

  @override
  Future<CorrectionResult?> correctText(String userText,
          {required CefrLevel level}) =>
      llmClient.correctText(userText, level: level);
}
