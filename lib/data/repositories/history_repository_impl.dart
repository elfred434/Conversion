import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_conversation_app/domain/entities/conversation_message.dart';
import 'package:english_conversation_app/domain/repositories/history_repository.dart';

/// Persistance locale de l'historique des conversations (SharedPreferences).
class HistoryRepositoryImpl implements HistoryRepository {
  @override
  Future<List<ConversationMessage>> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('history_$key');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => ConversationMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(String key, List<ConversationMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'history_$key',
      jsonEncode(messages.map((m) => m.toJson()).toList()),
    );
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('history_'));
    for (final k in keys) await prefs.remove(k);
  }
}
