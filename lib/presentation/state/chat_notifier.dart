import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_conversation_app/domain/entities/conversation_message.dart';
import 'package:english_conversation_app/domain/entities/level.dart';
import 'package:english_conversation_app/domain/entities/scenario.dart';
import 'package:english_conversation_app/domain/usecases/start_conversation.dart';
import 'package:english_conversation_app/domain/usecases/send_message.dart';
import 'package:english_conversation_app/domain/usecases/correct_text.dart';
import 'package:english_conversation_app/domain/repositories/history_repository.dart';
import 'package:english_conversation_app/presentation/state/chat_state.dart';

/// Orchestre la conversation : streaming, historique et corrections.
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._start, this._send, this._correct, this._history)
      : super(const ChatState());

  final StartConversation _start;
  final SendMessage _send;
  final CorrectText _correct;
  final HistoryRepository _history;

  CefrLevel? _level;
  String? _scenarioId;
  int _counter = 0;

  String _newId() => 'm${_counter++}_${DateTime.now().microsecondsSinceEpoch}';
  String get _historyKey => _scenarioId ?? 'free';

  /// Reduit les infos sensibles (cle API) des messages d'erreur affiches a l'utilisateur.
  String _redact(String message) =>
      message.replaceAll(RegExp(r'key=[^&\s"]+'), 'key=***');

  /// Demarre une nouvelle conversation (ou restaure l'historique existant).
  Future<void> start({required CefrLevel level, String? scenarioId}) async {
    _level = level;
    _scenarioId = scenarioId;

    final saved = await _history.load(_historyKey);
    if (saved.isNotEmpty) {
      state = ChatState(messages: saved);
      return;
    }

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
      _persist();
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
      _persist();
    }

    _applyCorrection(userMsg.id, trimmed);
  }

  void _persist() {
    _history.save(_historyKey, state.messages);
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

  /// Corrige la phrase de l'utilisateur (best-effort, non bloquant).
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
      final corrected = await _correct(userText: userText, level: _level!);
      if (corrected == null) return;
      state = state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.id == messageId)
              m.copyWith(correction: corrected)
            else
              m,
        ],
      );
    } catch (_) {
      // Erreur de correction non bloquante.
    }
  }
}
