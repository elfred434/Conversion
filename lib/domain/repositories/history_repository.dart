import 'package:english_conversation_app/domain/entities/conversation_message.dart';

abstract class HistoryRepository {
  Future<List<ConversationMessage>> load(String key);
  Future<void> save(String key, List<ConversationMessage> messages);
  Future<void> clearAll();
}
