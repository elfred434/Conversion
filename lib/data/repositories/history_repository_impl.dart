import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_conversation_app/domain/entities/conversation_session.dart';
import 'package:english_conversation_app/domain/repositories/history_repository.dart';

/// Persistance locale des sessions de conversation (SharedPreferences).
class HistoryRepositoryImpl implements HistoryRepository {
  static const _key = 'sessions';

  Future<List<ConversationSession>> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => ConversationSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _write(List<ConversationSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(sessions.map((s) => s.toJson()).toList()),
    );
  }

  @override
  Future<List<ConversationSession>> listSessions() => _read();

  @override
  Future<ConversationSession?> getSession(String id) async {
    final all = await _read();
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Future<void> saveSession(ConversationSession session) async {
    final all = await _read();
    final idx = all.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      all[idx] = session;
    } else {
      all.add(session);
    }
    await _write(all);
  }

  @override
  Future<void> deleteSession(String id) async {
    final all = await _read();
    all.removeWhere((s) => s.id == id);
    await _write(all);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
