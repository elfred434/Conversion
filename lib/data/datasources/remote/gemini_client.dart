import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:english_conversation_app/domain/entities/conversation_message.dart';
import 'package:english_conversation_app/domain/entities/level.dart';
import 'package:english_conversation_app/data/datasources/remote/llm_client.dart';

/// Implementation Google Gemini (streaming SSE via alt=sse).
class GeminiClient implements LlmClient {
  GeminiClient({required this.apiKey, this.model = 'gemini-1.5-flash'});

  final String apiKey;
  final String model;

  Map<String, Object> _body(
    ConversationMessage systemPrompt,
    List<ConversationMessage> history,
    ConversationMessage userMessage,
  ) {
    final contents = <Map<String, Object>>[
      for (final m in history)
        {
          'role': m.role == MessageRole.user ? 'user' : 'model',
          'parts': [
            {'text': m.content}
          ],
        },
      {
        'role': 'user',
        'parts': [
          {'text': userMessage.content}
        ],
      },
    ];
    return {
      'contents': contents,
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt.content}
        ]
      },
      'generationConfig': {'temperature': 0.7},
    };
  }

  @override
  Stream<String> streamChat({
    required ConversationMessage systemPrompt,
    required List<ConversationMessage> history,
    required ConversationMessage userMessage,
  }) async* {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model'
      ':streamGenerateContent?alt=sse&key=$apiKey',
    );

    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(_body(systemPrompt, history, userMessage));

    final response = await request.send();
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw Exception('Gemini error ${response.statusCode}: $body');
    }

    await for (final line in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (!line.startsWith('data:')) continue;
      final data = line.substring(5).trim();
      if (data.isEmpty) continue;
      try {
        final json = jsonDecode(data) as Map<String, dynamic>;
        final candidates = json['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) continue;
        final parts = candidates[0]['content']?['parts'] as List?;
        for (final p in parts ?? <dynamic>[]) {
          final text = (p as Map)['text'] as String?;
          if (text != null && text.isNotEmpty) yield text;
        }
      } catch (_) {
        // Ignorer les lignes SSE partielles.
      }
    }
  }

  @override
  Future<String?> correctText(String userText, {required CefrLevel level}) async {
    final prompt = 'You are an English teacher. Correct the following sentence '
        'for a ${level.name.toUpperCase()} learner. Return ONLY the corrected '
        'sentence, with no explanation or quotation marks.\n\n"$userText"';

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model'
      ':generateContent?key=$apiKey',
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {'temperature': 0},
      }),
    );
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;
    final parts = candidates[0]['content']?['parts'] as List?;
    if (parts == null || parts.isEmpty) return null;
    return (parts[0] as Map)['text'] as String?;
  }
}
