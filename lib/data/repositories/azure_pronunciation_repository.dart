import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:english_conversation_app/domain/entities/pronunciation_assessment.dart';
import 'package:english_conversation_app/domain/repositories/pronunciation_repository.dart';

/// Implementation Azure Speech - Pronunciation Assessment.
class AzurePronunciationRepository implements PronunciationRepository {
  final String key;
  final String region;

  AzurePronunciationRepository({required this.key, required this.region});

  @override
  Future<PronunciationAssessment?> assess({
    required String referenceText,
    required Uint8List audioBytes,
  }) async {
    final url = Uri.parse(
      'https://$region.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US&format=detailed',
    );
    final assessmentConfig = jsonEncode({
      'ReferenceText': referenceText,
      'GradingSystem': 'HundredMark',
      'Dimension': 'Comprehensive',
      'EnableMiscue': true,
    });
    final response = await http.post(
      url,
      headers: {
        'Ocp-Apim-Subscription-Key': key,
        'Content-Type': 'audio/wav; codecs=audio/pcm; samplerate=16000',
        'Pronunciation-Assessment': assessmentConfig,
      },
      body: audioBytes,
    );
    if (response.statusCode != 200) {
      throw Exception('Azure error ${response.statusCode}: ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final nbest = json['NBest'] as List?;
    if (nbest == null || nbest.isEmpty) return null;
    final top = nbest[0] as Map<String, dynamic>;
    final pa = top['PronunciationAssessment'] as Map<String, dynamic>? ?? {};
    final wordsRaw = top['Words'] as List? ?? [];
    final words = wordsRaw.map((w) {
      final wMap = w as Map<String, dynamic>;
      final wpa = wMap['PronunciationAssessment'] as Map<String, dynamic>? ?? {};
      return WordScore(
        wMap['Word'] as String? ?? '',
        _toDouble(wpa['AccuracyScore']),
      );
    }).toList();
    return PronunciationAssessment(
      overall: _toDouble(pa['PronScore']),
      accuracy: _toDouble(pa['AccuracyScore']),
      fluency: _toDouble(pa['FluencyScore']),
      completeness: _toDouble(pa['CompletenessScore']),
      prosody: _toDouble(pa['ProsodyScore']),
      words: words,
    );
  }

  double _toDouble(dynamic v) => (v is num) ? v.toDouble() : 0.0;
}
