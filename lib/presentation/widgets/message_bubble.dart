import 'package:flutter/material.dart';
import 'package:english_conversation_app/domain/entities/conversation_message.dart';

/// Bulle de message (utilisateur a droite, assistant a gauche).
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ConversationMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final isSystem = message.role == MessageRole.system;
    if (isSystem) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content.isEmpty ? '…' : message.content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
            if (message.correction != null) ...[
              const SizedBox(height: 6),
              Text(
                'Correction : ${message.correction}',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isUser ? Colors.white70 : Colors.green.shade800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
