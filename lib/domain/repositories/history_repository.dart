import 'package:english_conversation_app/domain/entities/conversation_session.dart';

abstract class HistoryRepository {
  Future<List<ConversationSession>> listSessions();
  Future<ConversationSession?> getSession(String id);
  Future<void> saveSession(ConversationSession session);
  Future<void> deleteSession(String id);
  Future<void> clearAll();
}
