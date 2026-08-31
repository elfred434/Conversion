import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_conversation_app/domain/entities/conversation_message.dart';
import 'package:english_conversation_app/presentation/providers/tts_provider.dart';

/// Bulle de message (utilisateur a droite, assistant a gauche).
class MessageBubble extends ConsumerWidget {
  const MessageBubble({super.key, required this.message});

  final ConversationMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.role == MessageRole.user;
    final isSystem = message.role == MessageRole.system;
    if (isSystem) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final content = message.content.isEmpty ? '…' : message.content;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
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
            if (!isUser)
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.volume_up, size: 20),
                tooltip: 'Lire a voix haute',
                onPressed: () async {
                  final tts = ref.read(flutterTtsProvider);
                  await tts.setLanguage('en-US');
                  await tts.speak(content);
                },
              ),
          ],
        ),
      ),
    );
  }
}
