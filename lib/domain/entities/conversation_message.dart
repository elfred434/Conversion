/// Role d'un message dans la conversation.
enum MessageRole { user, assistant, system }

int _idCounter = 0;
String _nextId() => 'm${_idCounter++}_${DateTime.now().microsecondsSinceEpoch}';

/// Message de conversation (entite du domaine, independante de tout SDK).
class ConversationMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  /// Correction grammaticale eventuelle (pour les messages de l'utilisateur).
  final String? correction;
  final bool isError;

  ConversationMessage({
    required this.id,
    required this.role,
    required this.content,
    this.correction,
    this.isError = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ConversationMessage.user(String content, {String? id}) =>
      ConversationMessage(
        id: id ?? _nextId(),
        role: MessageRole.user,
        content: content,
      );

  factory ConversationMessage.assistant(String content, {String? id}) =>
      ConversationMessage(
        id: id ?? _nextId(),
        role: MessageRole.assistant,
        content: content,
      );

  factory ConversationMessage.system(String content) => ConversationMessage(
        id: 'system',
        role: MessageRole.system,
        content: content,
      );

  ConversationMessage copyWith({
    String? content,
    String? correction,
    bool? isError,
  }) =>
      ConversationMessage(
        id: id,
        role: role,
        content: content ?? this.content,
        correction: correction ?? this.correction,
        isError: isError ?? this.isError,
        createdAt: createdAt,
      );
}
