import 'package:english_conversation_app/domain/entities/conversation_message.dart';

/// Une session de conversation sauvegardee (titre, scenario, messages).
class ConversationSession {
  final String id;
  final String title;
  final String scenarioId; // '' pour la conversation libre
  final DateTime createdAt;
  final List<ConversationMessage> messages;

  ConversationSession({
    required this.id,
    required this.title,
    required this.scenarioId,
    required this.messages,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Apercu : dernier message non-systeme.
  String get preview {
    ConversationMessage? last;
    for (final m in messages) {
      if (m.role != MessageRole.system) last = m;
    }
    return last?.content ?? '';
  }

  ConversationSession copyWith({
    String? title,
    List<ConversationMessage>? messages,
  }) =>
      ConversationSession(
        id: id,
        title: title ?? this.title,
        scenarioId: scenarioId,
        messages: messages ?? this.messages,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'scenarioId': scenarioId,
        'createdAt': createdAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ConversationSession.fromJson(Map<String, dynamic> json) =>
      ConversationSession(
        id: json['id'] as String,
        title: json['title'] as String,
        scenarioId: json['scenarioId'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        messages: (json['messages'] as List)
            .map((e) => ConversationMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
