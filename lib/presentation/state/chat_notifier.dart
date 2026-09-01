import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_conversation_app/domain/entities/conversation_message.dart';
import 'package:english_conversation_app/domain/entities/level.dart';
import 'package:english_conversation_app/domain/entities/scenario.dart';
import 'package:english_conversation_app/domain/entities/conversation_session.dart';
import 'package:english_conversation_app/domain/usecases/start_conversation.dart';
import 'package:english_conversation_app/domain/usecases/send_message.dart';
import 'package:english_conversation_app/domain/usecases/correct_text.dart';
import 'package:english_conversation_app/domain/repositories/history_repository.dart';
import 'package:english_conversation_app/domain/repositories/progress_repository.dart';
import 'package:english_conversation_app/presentation/state/chat_state.dart';

/// Orchestre la conversation : streaming, historique et corrections.
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(
    this._start,
    this._send,
    this._correct,
    this._history,
    this._progress,
  ) : super(const ChatState());

  final StartConversation _start;
  final SendMessage _send;
  final CorrectText _correct;
  final HistoryRepository _history;
  final ProgressRepository _progress;

  CefrLevel? _level;
  String? _scenarioId;
  String? _sessionId;
  String _sessionTitle = '';
  int _counter = 0;

  String _newId() => 'm${_counter++}_${DateTime.now().microsecondsSinceEpoch}';

  String _resolveTitle(String? scenarioId) {
    if (scenarioId == null) return 'Conversation libre';
    for (final s in kScenarios) {
      if (s.id == scenarioId) return s.title;
    }
    return 'Conversation';
  }

  /// Reduit les infos sensibles (cle API) des messages d'erreur affiches a l'utilisateur.
  String _redact(String message) =>
      message.replaceAll(RegExp(r'key=[^&\s"]+'), 'key=***');

  /// Demarre une conversation : reprend une session existante (sessionId) ou
  /// en cree une nouvelle (salutation du tuteur).
  Future<void> start({
    required CefrLevel level,
    String? scenarioId,
    String? sessionId,
  }) async {
    _level = level;
    _scenarioId = scenarioId;

    if (sessionId != null) {
      final session = await _history.getSession(sessionId);
      if (session != null) {
        _sessionId = session.id;
        _sessionTitle = session.title;
        state = ChatState(messages: session.messages);
        return;
      }
    }

    _sessionId = _newId();
    _sessionTitle = _resolveTitle(scenarioId);

    state = ChatState(
      messages: [ConversationMessage.assistant('', id: _newId())],
      isStreaming: true,
    );

    final buffer = StringBuffer();
    try {
      await for (final chunk
          in _start(level: level, scenarioId: scenarioId)) {
        buffer.write(chunk);
        state = state.copyWith(messages: _updateAssistant(buffer.toString()));
      }
    } catch (e) {
      state = state.copyWith(error: _redact(e.toString()));
    } finally {
      state = state.copyWith(isStreaming: false);
      await _persist();
    }
  }

  /// Envoie un message utilisateur et diffuse la reponse.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isStreaming || _level == null) return;

    final userMsg = ConversationMessage.user(trimmed, id: _newId());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isStreaming: true,
      error: null,
    );

    final history = state.messages
        .where((m) => m.role != MessageRole.system)
        .toList();
    final assistantId = _newId();
    state = state.copyWith(
      messages: [
        ...state.messages,
        ConversationMessage.assistant('', id: assistantId),
      ],
    );

    final buffer = StringBuffer();
    try {
      await for (final chunk in _send(
        level: _level!,
        history: history,
        userText: trimmed,
        scenarioId: _scenarioId,
      )) {
        buffer.write(chunk);
        state = state.copyWith(
          messages: _updateAssistantById(assistantId, buffer.toString()),
        );
      }
    } catch (e) {
      state = state.copyWith(error: _redact(e.toString()));
    } finally {
      state = state.copyWith(isStreaming: false);
      await _persist();
    }

    _applyCorrection(userMsg.id, trimmed);
  }

  Future<void> _persist() async {
    if (_sessionId == null) return;
    final session = ConversationSession(
      id: _sessionId!,
      title: _sessionTitle,
      scenarioId: _scenarioId ?? '',
      messages: state.messages,
    );
    await _history.saveSession(session);
  }

  List<ConversationMessage> _updateAssistant(String content) {
    final list = [...state.messages];
    final idx = list.lastIndexWhere((m) => m.role == MessageRole.assistant);
    if (idx >= 0) list[idx] = list[idx].copyWith(content: content);
    return list;
  }

  List<ConversationMessage> _updateAssistantById(
    String id,
    String content,
  ) =>
      [
        for (final m in state.messages)
          if (m.id == id) m.copyWith(content: content) else m,
      ];

  /// Corrige la phrase de l'utilisateur (best-effort, non bloquant) et
  /// enregistre le type d'erreur pour le suivi de progression.
  void _applyCorrection(String messageId, String userText) async {
    if (_level == null) return;
    // Mode "ecoute" (ex: Raconte ta journee) : pas de correction.
    Scenario? scenario;
    for (final s in kScenarios) {
      if (s.id == _scenarioId) {
        scenario = s;
        break;
      }
    }
    if (scenario != null && !scenario.correct) return;
    try {
      final result = await _correct(userText: userText, level: _level!);
      if (result?.corrected == null || result!.corrected!.isEmpty) return;
      state = state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.id == messageId)
              m.copyWith(correction: result.corrected)
            else
              m,
        ],
      );
      if (result.category != null) {
        await _progress.recordCorrection(result.category!);
      }
    } catch (_) {
      // Erreur de correction non bloquante.
    }
  }
}
