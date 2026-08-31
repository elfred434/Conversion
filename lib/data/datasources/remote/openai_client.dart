import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:english_conversation_app/domain/entities/conversation_message.dart';
import 'package:english_conversation_app/domain/entities/level.dart';
import 'package:english_conversation_app/data/datasources/remote/llm_client.dart';

/// Implementation OpenAI Chat Completions (streaming SSE).
class OpenAiClient implements LlmClient {
  OpenAiClient({required this.apiKey, this.baseUrl = 'https://api.openai.com/v1'});

  final String apiKey;
  final String baseUrl;
  final String model = 'gpt-4o-mini';

  List<Map<String, String>> _toMessages(
    ConversationMessage systemPrompt,
    List<ConversationMessage> history,
    ConversationMessage userMessage,
  ) {
    return [
      {'role': 'system', 'content': systemPrompt.content},
      for (final m in history)
        {
          'role': m.role == MessageRole.user ? 'user' : 'assistant',
          'content': m.content,
        },
      {'role': 'user', 'content': userMessage.content},
    ];
  }

  @override
  Stream<String> streamChat({
    required ConversationMessage systemPrompt,
    required List<ConversationMessage> history,
    required ConversationMessage userMessage,
  }) async* {
    final request = http.Request(
      'POST',
      Uri.parse('$baseUrl/chat/completions'),
    )
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'text/event-stream'
      ..body = jsonEncode({
        'model': model,
        'messages': _toMessages(systemPrompt, history, userMessage),
        'stream': true,
        'temperature': 0.7,
      });

    final response = await request.send();
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw Exception('OpenAI error ${response.statusCode}: $body');
    }

    await for (final line in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (!line.startsWith('data:')) continue;
      final data = line.substring(5).trim();
      if (data == '[DONE]') break;
      try {
        final json = jsonDecode(data) as Map<String, dynamic>;
        final delta =
            json['choices']?[0]?['delta']?['content'] as String?;
        if (delta != null && delta.isNotEmpty) yield delta;
      } catch (_) {
        // Lignes SSE partielles ou keep-alive : on ignore.
      }
    }
  }

  @override
  Future<String?> correctText(String userText, {required CefrLevel level}) async {
    final prompt = 'You are an English teacher. Correct the following sentence '
        'for a ${level.name.toUpperCase()} learner. Return ONLY the corrected '
        'sentence, with no explanation or quotation marks.\n\n"$userText"';

    final request = http.Request(
      'POST',
      Uri.parse('$baseUrl/chat/completions'),
    )
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': prompt}
        ],
        'temperature': 0,
      });

    final response = await request.send();
    if (response.statusCode != 200) return null;
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final text = json['choices']?[0]?['message']?['content'] as String?;
    return text?.trim();
  }
}
