/// Score phonetique detaille (API Azure Pronunciation Assessment).
class WordScore {
  final String word;
  final double accuracy;
  const WordScore(this.word, this.accuracy);
}

class PronunciationAssessment {
  final double overall;
  final double accuracy;
  final double fluency;
  final double completeness;
  final double prosody;
  final List<WordScore> words;

  const PronunciationAssessment({
    required this.overall,
    required this.accuracy,
    required this.fluency,
    required this.completeness,
    required this.prosody,
    required this.words,
  });
}
