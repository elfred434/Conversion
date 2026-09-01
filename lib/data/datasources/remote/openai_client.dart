import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:english_conversation_app/domain/entities/conversation_message.dart';
import 'package:english_conversation_app/domain/entities/level.dart';
import 'package:english_conversation_app/domain/entities/correction_result.dart';
import 'package:english_conversation_app/data/datasources/remote/llm_client.dart';

/// Client compatible OpenAI (OpenAI, OpenRouter, Groq, Ollama, OVHcloud, HF...).
class OpenAiClient implements LlmClient {
  final String apiKey;
  final String baseUrl;
  final String model;

  OpenAiClient({
    required this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1',
    this.model = 'gpt-4o-mini',
  });

  String _role(ConversationMessage m) =>
      m.role == MessageRole.assistant ? 'assistant' : (m.role == MessageRole.system ? 'system' : 'user');

  @override
  Stream<String> streamChat({
    required ConversationMessage systemPrompt,
    required List<ConversationMessage> history,
    required ConversationMessage userMessage,
  }) async* {
    final messages = <Map<String, String>>[
      {'role': _role(systemPrompt), 'content': systemPrompt.content},
      for (final m in history) {'role': _role(m), 'content': m.content},
      {'role': _role(userMessage), 'content': userMessage.content},
    ];

    final request = http.Request('POST', Uri.parse('$baseUrl/chat/completions'))
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'text/event-stream'
      ..body = jsonEncode({
        'model': model,
        'messages': messages,
        'stream': true,
      });

    final response = await request.send();
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw Exception('OpenAI error ${response.statusCode}: $body');
    }
    await for (final line
        in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
      if (!line.startsWith('data:')) continue;
      final data = line.substring(5).trim();
      if (data == '[DONE]') break;
      final json = jsonDecode(data) as Map<String, dynamic>;
      final delta = json['choices']?[0]?['delta']?['content'];
      if (delta is String && delta.isNotEmpty) yield delta;
    }
  }

  @override
  Future<CorrectionResult?> correctText(String userText,
      {required CefrLevel level}) async {
    final prompt = '''
You are an English teacher. The student (CEFR level: ${level.label}) wrote:
"$userText"
Correct the text if needed. Reply ONLY with strict JSON:
{"has_error": true/false, "corrected": "<corrected text or empty if none>", "explanation": "<short explanation in English>", "category": "<one of: article, preposition, tense, spelling, word_order, other, or empty if no error>"}
''';
    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': 'You are a helpful English teacher.'},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.2,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('OpenAI error ${response.statusCode}: ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        json['choices']?[0]?['message']?['content'] as String? ?? '';
    try {
      final parsed = jsonDecode(
              content.replaceAll(RegExp(r'```json|```'), '').trim())
          as Map<String, dynamic>;
      final hasError = parsed['has_error'] == true ||
          (parsed['corrected'] is String &&
              (parsed['corrected'] as String).isNotEmpty);
      return CorrectionResult(
        corrected: parsed['corrected'] as String?,
        explanation: parsed['explanation'] as String?,
        category: hasError ? (parsed['category'] as String? ?? 'other') : null,
      );
    } catch (_) {
      return null;
    }
  }
}
