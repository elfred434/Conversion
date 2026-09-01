/// Resultat de la correction grammaticale renvoye par le LLM.
class CorrectionResult {
  final String? corrected;
  final String? explanation;
  /// Type d'erreur (article, preposition, tense, spelling, word_order, other).
  final String? category;

  const CorrectionResult({this.corrected, this.explanation, this.category});
}
