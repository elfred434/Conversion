import 'dart:typed_data';
import 'package:english_conversation_app/domain/entities/pronunciation_assessment.dart';

/// Evaluation phonetique d'un enregistrement audio vs un texte de reference.
abstract class PronunciationRepository {
  Future<PronunciationAssessment?> assess({
    required String referenceText,
    required Uint8List audioBytes,
  });
}
