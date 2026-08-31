import 'package:english_conversation_app/domain/entities/conversation_message.dart';

/// Etat de l'ecran de conversation.
class ChatState {
  final List<ConversationMessage> messages;
  final bool isStreaming;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.error,
  });

  ChatState copyWith({
    List<ConversationMessage>? messages,
    bool? isStreaming,
    String? error,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isStreaming: isStreaming ?? this.isStreaming,
        error: error ?? this.error,
      );
}
